package com.scanmyfood.backend.models;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Quantity {
    private Double value;
    private String unit;

    public void setValue(Double value) {
        if (value != null){
            this.value = Math.round(value * 100.0) / 100.0;
        } else {
            this.value = null;
        }
    }
}
