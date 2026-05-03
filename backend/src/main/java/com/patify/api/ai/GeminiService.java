package com.patify.api.ai;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.List;
import java.util.Map;

@Service
public class GeminiService {

    @Value("${gemini.api.key}")
    private String apiKey;

    @Value("${gemini.api.url}")
    private String apiUrl;

    private final WebClient webClient;

    public GeminiService(WebClient.Builder webClientBuilder) {
        this.webClient = webClientBuilder.build();
    }

    public String askQuestion(String question) {
        if (apiKey == null || apiKey.isBlank()) {
            return "Şu anda cevap üretilemedi.";
        }

        String prompt = """
        You are an AI pet assistant for an animal support application.

        Your role is limited to animal and pet-related topics only.
        Only answer questions about pets, animals, pet care, feeding, behavior, grooming,
        shelters, adoption, lost pets, and general animal well-being.

        If the user's question is not related to animals or pets, do not answer it.
        Instead, reply in Turkish with this exact sentence:
        "Ben sadece hayvanlar ve evcil hayvanlarla ilgili sorularda yardimci olabilirim."

        Give short, practical, clear, and safe answers in Turkish.
        Do not make certain diagnoses.
        Do not prescribe medication doses.
        Do not give dangerous, illegal, or harmful instructions.
        If the issue may be urgent, tell the user to contact a veterinarian immediately.

        Do not use markdown.
        Do not use ** symbols.
        Do not use headings.
        Keep formatting simple and readable.
        If needed, use short plain lines.

        User question: %s
        """.formatted(question);

        Map<String, Object> requestBody = Map.of(
                "contents", List.of(
                        Map.of(
                                "parts", List.of(
                                        Map.of("text", prompt)
                                )
                        )
                )
        );

        Map response = webClient.post()
                .uri(apiUrl + "?key=" + apiKey)
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(requestBody)
                .retrieve()
                .bodyToMono(Map.class)
                .block();

        try {
            List candidates = (List) response.get("candidates");
            Map firstCandidate = (Map) candidates.get(0);
            Map content = (Map) firstCandidate.get("content");
            List parts = (List) content.get("parts");
            Map firstPart = (Map) parts.get(0);
            return firstPart.get("text").toString();
        } catch (Exception e) {
            return "Şu anda cevap üretilemedi.";
        }
    }
}
