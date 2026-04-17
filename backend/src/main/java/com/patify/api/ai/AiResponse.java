package com.patify.api.ai;

public class AiResponse {
    private String answer;

    public AiResponse() {}

    public AiResponse(String answer) {
        this.answer = answer;
    }

    public String getAnswer() {
        return answer;
    }

    public void setAnswer(String answer) {
        this.answer = answer;
    }
}