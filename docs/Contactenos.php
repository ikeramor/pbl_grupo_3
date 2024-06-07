<?php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $name = $_POST['name'];
    $email = $_POST['email'];
    $phone = $_POST['phone'];
    $message = $_POST['message'];

    // Establecer el destinatario del correo electrónico
    $to = "ane.zabalam@alumni.mondragon.edu";

    // Establecer el remitente y otras cabeceras del correo electrónico
    $subject = "Nuevo mensaje de contacto de " . $name;
    $headers = "From: $name <$email>\r\n"; // Establecer el remitente
    $headers .= "Reply-To: $email\r\n"; // Establecer la dirección de respuesta

    // Construir el cuerpo del mensaje
    $body = "Nombre: " . $name . "\n";
    $body .= "Correo electrónico: " . $email . "\n";
    $body .= "Teléfono: " . $phone . "\n";
    $body .= "Mensaje: " . $message;

    // Enviar el correo electrónico
    mail($to, $subject, $body, $headers);

    // Redirigir al usuario a una página de confirmación o mostrar un mensaje de éxito
    header("Location: confirmacion.html");
    exit(); // Terminar el script después de redirigir
}
?>