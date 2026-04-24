package com.scanmyfood.backend.mapper;

import org.apache.ibatis.type.BaseTypeHandler;
import org.apache.ibatis.type.JdbcType;
import org.apache.ibatis.type.MappedJdbcTypes;
import org.apache.ibatis.type.MappedTypes;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Collections;
import java.util.List;

@MappedJdbcTypes({JdbcType.VARCHAR, JdbcType.LONGVARCHAR})
@MappedTypes(List.class)
public class StringListTypeHandler extends BaseTypeHandler<List<String>> {

    private static final ObjectMapper mapper = new ObjectMapper();

    @Override
    public void setNonNullParameter(PreparedStatement ps, int i, List<String> parameter, JdbcType jdbcType) throws SQLException {
        try {
            ps.setString(i, mapper.writeValueAsString(parameter));
        } catch (JsonProcessingException e) {
            throw new SQLException("Error converting list to JSON", e);
        }
    }

    @Override
    public List<String> getNullableResult(ResultSet rs, String columnName) throws SQLException {
        return parseJson(rs.getString(columnName));
    }

    @Override
    public List<String> getNullableResult(ResultSet rs, int columnIndex) throws SQLException {
        return parseJson(rs.getString(columnIndex));
    }

    @Override
    public List<String> getNullableResult(CallableStatement cs, int columnIndex) throws SQLException {
        return parseJson(cs.getString(columnIndex));
    }

    private List<String> parseJson(String json) throws SQLException {
        if (json == null || json.trim().isEmpty() || "{}".equals(json.trim()) || "[]".equals(json.trim())) {
            return Collections.emptyList();
        }
        json = json.trim();
        
        // Check if it's a PostgreSQL native array string format like {wheat,barley,rye}
        if (json.startsWith("{") && json.endsWith("}")) {
            // It's a Postgres array literal, not JSON. It starts with { and ends with }
            // For simple strings, we can just strip the braces and split by comma
            String content = json.substring(1, json.length() - 1);
            if (content.isEmpty()) {
                return Collections.emptyList();
            }
            
            // Note: This simple split handles basic strings without commas inside them.
            // For complex strings with quotes, a more robust CSV parser would be needed,
            // but this covers standard health condition data.
            String[] elements = content.split(",");
            for (int i = 0; i < elements.length; i++) {
                // Remove optional quotes that Postgres might add around elements
                String el = elements[i].trim();
                if (el.startsWith("\"") && el.endsWith("\"") && el.length() >= 2) {
                    el = el.substring(1, el.length() - 1);
                }
                elements[i] = el;
            }
            return java.util.Arrays.asList(elements);
        }
        
        // Otherwise try parsing it as standard JSON
        try {
            return mapper.readValue(json, new TypeReference<List<String>>() {});
        } catch (JsonProcessingException e) {
            throw new SQLException("Error parsing JSON to list: " + json, e);
        }
    }
}
