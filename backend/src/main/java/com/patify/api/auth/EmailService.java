package com.patify.api.auth;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class EmailService {
  private final JavaMailSender mailSender;
  private final String from;

  public EmailService(
      JavaMailSender mailSender,
      @Value("${app.mail.from:no-reply@patify.local}") String from
  ) {
    this.mailSender = mailSender;
    this.from = from;
  }

  public void sendVerificationEmail(String to, String verificationUrl) {
    SimpleMailMessage message = new SimpleMailMessage();
    message.setFrom(from);
    message.setTo(to);
    message.setSubject("Patify email dogrulama");
    message.setText(
        "Patify hesabini dogrulamak icin asagidaki linke tikla:\n\n"
            + verificationUrl
            + "\n\nBu linkin suresi dolabilir. Bu istegi sen yapmadiysan bu e-postayi yok sayabilirsin."
    );
    mailSender.send(message);
  }
}
