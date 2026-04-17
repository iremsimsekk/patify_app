package com.patify.api.ai;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/ai")
@CrossOrigin(origins = "*")
public class AiController {

    private final GeminiService geminiService;

    public AiController(GeminiService geminiService) {
        this.geminiService = geminiService;
    }

    @PostMapping("/ask")
    public ResponseEntity<AiResponse> ask(@RequestBody AiRequest request) {
        if (request.getQuestion() == null || request.getQuestion().trim().isEmpty()) {
            return ResponseEntity.badRequest().body(new AiResponse("Soru boş olamaz."));
        }

        String answer = geminiService.askQuestion(request.getQuestion());
        return ResponseEntity.ok(new AiResponse(answer));
    }
}