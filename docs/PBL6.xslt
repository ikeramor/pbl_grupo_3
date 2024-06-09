<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" encoding="UTF-8" />

  <xsl:template match="/">
    <html>
      <head>
        <title>Tabla de Pacientes</title>
        <style>
          body {
            background-color: #2c345e;
            color: #fff;
            font-family: Arial, sans-serif;
          }
          table {
            width: 100%;
            border-collapse: collapse;
            background-color: #2c345e; /* Cambiado a #2c345e */
            color: #fff;
          }
          th, td {
            border: 1px solid black;
            padding: 8px;
            text-align: left;
          }
          th {
            background-color: #ff046f;
            color: #fff;
          }
          h2 {
            text-align: center;
            color: #fff;
            text-transform: uppercase;
          }
        </style>
      </head>
      <body>
        <h2>Tabla de Pacientes</h2>
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>Especialista</th>
              <th>Fecha de Adquisición</th>
              <th>Fecha de Diagnóstico</th>
              <th>Imagen</th>
              <th>Resultado</th>
            </tr>
          </thead>
          <tbody>
            <xsl:apply-templates select="//Paciente"/>
          </tbody>
        </table>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="Paciente">
    <tr>
      <td><xsl:value-of select="@id"/></td>
      <td><xsl:value-of select="InformacionDeExtraccion/Especialista"/></td>
      <td><xsl:value-of select="InformacionDeExtraccion/FechaDeAdquisicion"/></td>
      <td><xsl:value-of select="Diagnostico/FechaDiagnostico"/></td>
      <td><xsl:value-of select="InformacionDeLaImagen/Imagen"/></td>
      <td><xsl:value-of select="Diagnostico/ResultadoDiagnostico"/></td>
    </tr>
  </xsl:template>
  
</xsl:stylesheet>

