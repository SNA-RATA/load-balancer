package ru.rata.loadbalancer;

import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
public class NoteController {

    private final JdbcTemplate jdbcTemplate;
    private final String serverId;

    public NoteController(JdbcTemplate jdbcTemplate, @Value("${app.server-id}") String serverId) {
        this.jdbcTemplate = jdbcTemplate;
        this.serverId = serverId;
    }

    @GetMapping("/")
    public Map<String, String> readNote() {
        String note = jdbcTemplate.query(
                "SELECT text FROM notes ORDER BY id LIMIT 1",
                resultSet -> resultSet.next() ? resultSet.getString("text") : null
        );
        if (note == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "No notes found");
        }
        return Map.of(
                "server_id", serverId,
                "note", note
        );
    }
}
