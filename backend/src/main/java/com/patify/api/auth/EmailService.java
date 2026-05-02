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

  public void sendVeterinarianApprovalEmail(
      String to,
      String veterinarianEmail,
      String clinicName,
      String clinicAddress,
      String clinicEmail,
      String approveUrl,
      String rejectUrl
  ) {
    SimpleMailMessage message = new SimpleMailMessage();
    message.setFrom(from);
    message.setTo(to);
    message.setSubject("Patify veteriner sahiplenme onayi gerekiyor");
    message.setText(
        "Yeni bir veteriner sahiplenme talebi olusturuldu.\n\n"
            + "Talep eden veteriner: " + veterinarianEmail + "\n"
            + "Klinik adi: " + clinicName + "\n"
            + "Klinik adresi: " + clinicAddress + "\n"
            + "Klinik emaili: " + (clinicEmail == null || clinicEmail.isBlank() ? "-" : clinicEmail) + "\n\n"
            + "Onayla: " + approveUrl + "\n"
            + "Reddet: " + rejectUrl + "\n"
    );
    mailSender.send(message);
  }

  public void sendVeterinarianCancelledAppointmentEmail(
      String to,
      String clinicName,
      String appointmentDate,
      String appointmentTime,
      String reason
  ) {
    SimpleMailMessage message = new SimpleMailMessage();
    message.setFrom(from);
    message.setTo(to);
    message.setSubject("Patify randevunuz veteriner tarafindan iptal edildi");
    message.setText(
        clinicName
            + " icin "
            + appointmentDate
            + " "
            + appointmentTime
            + " tarihli randevunuz veteriner tarafindan iptal edilmistir.\n\n"
            + "Iptal aciklamasi: "
            + reason
            + "\n\n"
            + "Lutfen Patify uzerinden baska bir uygun randevu seciniz."
    );
    mailSender.send(message);
  }
}
