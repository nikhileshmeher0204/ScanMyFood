package com.scanmyfood.backend.mapper;

import org.apache.ibatis.type.BaseTypeHandler;
import org.apache.ibatis.type.JdbcType;
import org.apache.ibatis.type.MappedJdbcTypes;
import org.apache.ibatis.type.MappedTypes;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.scanmyfood.backend.models.RecipeItem;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Collections;
import java.util.List;

@MappedJdbcTypes({JdbcType.VARCHAR, JdbcType.OTHER})
@MappedTypes(List.class)
public class RecipeItemListTypeHandler extends BaseTypeHandler<List<RecipeItem>> {

    private static final ObjectMapper mapper = new ObjectMapper();

    @Override
    public void setNonNullParameter(PreparedStatement ps, int i, List<RecipeItem> parameter, JdbcType jdbcType) throws SQLException {
        try {
            ps.setString(i, mapper.writeValueAsString(parameter));
        } catch (JsonProcessingException e) {
            throw new SQLException("Error converting RecipeItem list to JSON", e);
        }
    }

    @Override
    public List<RecipeItem> getNullableResult(ResultSet rs, String columnName) throws SQLException {
        return parseJson(rs.getString(columnName));
    }

    @Override
    public List<RecipeItem> getNullableResult(ResultSet rs, int columnIndex) throws SQLException {
        return parseJson(rs.getString(columnIndex));
    }

    @Override
    public List<RecipeItem> getNullableResult(CallableStatement cs, int columnIndex) throws SQLException {
        return parseJson(cs.getString(columnIndex));
    }

    private List<RecipeItem> parseJson(String json) throws SQLException {
        if (json == null || json.trim().isEmpty() || "{}".equals(json.trim()) || "[]".equals(json.trim())) {
            return Collections.emptyList();
        }
        try {
            return mapper.readValue(json, new TypeReference<List<RecipeItem>>() {});
        } catch (JsonProcessingException e) {
            throw new SQLException("Error parsing JSON to RecipeItem list: " + json, e);
        }
    }
}
