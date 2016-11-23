<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" >
<xsl:output method="text" omit-xml-declaration="yes" />
<xsl:strip-space elements="*"/>
  <xsl:variable name="quot" >"</xsl:variable>
  <xsl:variable name="apos" >'</xsl:variable>
  <xsl:variable name="LCID" >1033</xsl:variable>
  
<xsl:template match="/">"Term Set Name","Term Set Description","LCID","Available for Tagging","Term Description","Level 1 Term","Level 2 Term","Level 3 Term","Level 4 Term","Level 5 Term","Level 6 Term","Level 7 Term"
"<xsl:value-of select="TermStore/TS/@a12"/>", "<xsl:value-of select="TermStore/TS/@a11"/>",,TRUE,,,,,,,,
<xsl:for-each select="TermStore/T[not(TMS/TM/@a25)]"><xsl:variable name="l1_GUID" select="@a9" /><xsl:variable name="l1" select="translate(LS/TL[@a31='true']/@a32,$quot,$apos)" />,,<xsl:value-of select="$LCID"/>,TRUE,"<xsl:call-template name="description"><xsl:with-param name="item" select="current()"/></xsl:call-template>","<xsl:value-of select="$l1"/>",,,,,,
<xsl:for-each select="ancestor::TermStore/T[TMS/TM/@a25=$l1_GUID]"><xsl:variable name="l2_GUID" select="@a9" /><xsl:variable name="l2" select="translate(LS/TL[@a31='true']/@a32,$quot,$apos)" />,,<xsl:value-of select="$LCID"/>,TRUE,"<xsl:call-template name="description"><xsl:with-param name="item" select="current()"/></xsl:call-template>","<xsl:value-of select="$l1"/>","<xsl:value-of select="$l2"/>",,,,,
<xsl:for-each select="ancestor::TermStore/T[TMS/TM/@a25=$l2_GUID]"><xsl:variable name="l3_GUID" select="@a9" /><xsl:variable name="l3" select="translate(LS/TL[@a31='true']/@a32,$quot,$apos)" />,,<xsl:value-of select="$LCID"/>,TRUE,"<xsl:call-template name="description"><xsl:with-param name="item" select="current()"/></xsl:call-template>","<xsl:value-of select="$l1"/>","<xsl:value-of select="$l2"/>","<xsl:value-of select="$l3"/>",,,,
<xsl:for-each select="ancestor::TermStore/T[TMS/TM/@a25=$l3_GUID]"><xsl:variable name="l4_GUID" select="@a9" /><xsl:variable name="l4" select="translate(LS/TL[@a31='true']/@a32,$quot,$apos)" />,,<xsl:value-of select="$LCID"/>,TRUE,"<xsl:call-template name="description"><xsl:with-param name="item" select="current()"/></xsl:call-template>","<xsl:value-of select="$l1"/>","<xsl:value-of select="$l2"/>","<xsl:value-of select="$l3"/>","<xsl:value-of select="$l4"/>",,,
<xsl:for-each select="ancestor::TermStore/T[TMS/TM/@a25=$l4_GUID]"><xsl:variable name="l5_GUID" select="@a9" /><xsl:variable name="l5" select="translate(LS/TL[@a31='true']/@a32,$quot,$apos)" />,,<xsl:value-of select="$LCID"/>,TRUE,"<xsl:call-template name="description"><xsl:with-param name="item" select="current()"/></xsl:call-template>","<xsl:value-of select="$l1"/>","<xsl:value-of select="$l2"/>","<xsl:value-of select="$l3"/>","<xsl:value-of select="$l4"/>","<xsl:value-of select="$l5"/>",,
<xsl:for-each select="ancestor::TermStore/T[TMS/TM/@a25=$l5_GUID]"><xsl:variable name="l6_GUID" select="@a9" /><xsl:variable name="l6" select="translate(LS/TL[@a31='true']/@a32,$quot,$apos)" />,,<xsl:value-of select="$LCID"/>,TRUE,"<xsl:call-template name="description"><xsl:with-param name="item" select="current()"/></xsl:call-template>","<xsl:value-of select="$l1"/>","<xsl:value-of select="$l2"/>","<xsl:value-of select="$l3"/>","<xsl:value-of select="$l4"/>","<xsl:value-of select="$l5"/>","<xsl:value-of select="$l6"/>",
<xsl:for-each select="ancestor::TermStore/T[TMS/TM/@a25=$l6_GUID]"><xsl:variable name="l7" select="translate(LS/TL[@a31='true']/@a32,$quot,$apos)" />,,<xsl:value-of select="$LCID"/>,TRUE,"<xsl:call-template name="description"><xsl:with-param name="item" select="current()"/></xsl:call-template>","<xsl:value-of select="$l1"/>","<xsl:value-of select="$l2"/>","<xsl:value-of select="$l3"/>","<xsl:value-of select="$l4"/>","<xsl:value-of select="$l5"/>","<xsl:value-of select="$l6"/>","<xsl:value-of select="$l7"/>"
</xsl:for-each>
</xsl:for-each>
</xsl:for-each>
</xsl:for-each>
</xsl:for-each>
</xsl:for-each>
</xsl:for-each>
</xsl:template>

  <xsl:template name="description">
    <xsl:param name="item"/>
    <xsl:value-of select="translate($item/DS/TD/@a11,$quot,$apos)"/>
  </xsl:template>  
</xsl:stylesheet>