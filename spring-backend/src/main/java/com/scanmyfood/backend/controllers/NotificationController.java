package com.scanmyfood.backend.controllers;

import com.scanmyfood.backend.events.MealLoggedEvent;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.http.MediaType;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;

@Slf4j
@RestController
@RequestMapping("/api/notifications")
public class NotificationController {

    private final Map<String, List<SseEmitter>> userEmitters = new ConcurrentHashMap<>();

    @GetMapping(value = "/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter streamNotifications(@RequestParam String userId, HttpServletResponse response) {
        log.info("Client connected to notification stream for userId: {}", userId);

        // Prevent proxy buffering on Railway / Cloudflare / Nginx
        response.setHeader("X-Accel-Buffering", "no");
        response.setHeader("Cache-Control", "no-cache, no-transform");
        response.setHeader("Connection", "keep-alive");

        // Connection timeout: 24 hours (86,400,000 ms)
        SseEmitter emitter = new SseEmitter(86400000L);

        userEmitters.computeIfAbsent(userId, k -> new CopyOnWriteArrayList<>()).add(emitter);

        emitter.onCompletion(() -> removeEmitter(userId, emitter));
        emitter.onTimeout(() -> removeEmitter(userId, emitter));
        emitter.onError((e) -> removeEmitter(userId, emitter));

        try {
            emitter.send(SseEmitter.event()
                    .name("connected")
                    .data(Map.of("status", "connected", "event", "connected")));
        } catch (IOException e) {
            log.debug("Failed to send initial SSE connected event to user {}: {}", userId, e.getMessage());
            removeEmitter(userId, emitter);
            try {
                emitter.completeWithError(e);
            } catch (Exception ignored) {}
        }

        return emitter;
    }

    private void removeEmitter(String userId, SseEmitter emitter) {
        List<SseEmitter> emitters = userEmitters.get(userId);
        if (emitters != null) {
            emitters.remove(emitter);
            if (emitters.isEmpty()) {
                userEmitters.remove(userId, emitters);
            }
        }
    }

    @Scheduled(fixedRate = 15000)
    public void sendHeartbeat() {
        if (userEmitters.isEmpty()) return;
        userEmitters.forEach((userId, emitters) -> {
            List<SseEmitter> deadEmitters = new ArrayList<>();
            for (SseEmitter emitter : emitters) {
                try {
                    emitter.send(SseEmitter.event()
                            .name("ping")
                            .data(Map.of("event", "ping", "ts", System.currentTimeMillis())));
                } catch (Throwable e) {
                    deadEmitters.add(emitter);
                }
            }
            for (SseEmitter dead : deadEmitters) {
                removeEmitter(userId, dead);
            }
        });
    }

    @EventListener
    public void handleMealLoggedEvent(MealLoggedEvent event) {
        log.info("Received MealLoggedEvent for user: {}", event.getUserId());
        List<SseEmitter> emitters = userEmitters.get(event.getUserId());
        if (emitters != null && !emitters.isEmpty()) {
            List<SseEmitter> deadEmitters = new ArrayList<>();
            for (SseEmitter emitter : emitters) {
                try {
                    emitter.send(SseEmitter.event()
                            .name("meal_logged")
                            .data(Map.of(
                                    "event", "meal_logged",
                                    "dailyIntakeId", event.getDailyIntakeId()
                            )));
                } catch (Throwable e) {
                    log.debug("Failed to send SSE notification to emitter for user {}: {}", event.getUserId(), e.getMessage());
                    deadEmitters.add(emitter);
                    try {
                        emitter.completeWithError(e);
                    } catch (Exception ignored) {}
                }
            }
            for (SseEmitter dead : deadEmitters) {
                removeEmitter(event.getUserId(), dead);
            }
        }
    }
}
