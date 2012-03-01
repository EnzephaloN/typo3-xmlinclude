<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:output method="xml"/>

	<xsl:param name="pageURL"/>
	<xsl:param name="hostName"/>
	<xsl:param name="rewriteOnClass"/>
	<xsl:param name="rewriteOffClass"/>

	<!-- Copy -->
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>


	<!--
		Rewrite Links in a/@href elements
		* which are
			* without a target attribute AND
			* not marked with the $rewriteOffClass class AND
			* relative links OR http(s) links whose host name is the same as our target site’s
		* and those marked with the $rewriteOnClass class, regardless of other conditions
	-->
	<xsl:template match="xhtml:a/@href">
		<!-- Link is relative if does not contain :// -->
		<xsl:variable name="isRelativeLink" select="not(contains(., '://'))"/>
		<!-- Link is a http link if it does not begin with http:// or https:// -->
		<xsl:variable name="isHTTPLink" select="substring(., 1, 7) = 'http://' or
												substring(., 1, 8) = 'https://'"/>
		<!-- Link’s host name is between the :// and the next / for http(s) URLs. -->
		<xsl:variable name="HTTPHostName" select="substring-before(substring-after(., '://'), '/')"/>

		<xsl:attribute name="{local-name(.)}">
			<xsl:choose>
				<xsl:when test="( not(../@target) and
					not(contains(../@class, $rewriteOffClass)) and
					($isRelativeLink or ($isHTTPLink and $HTTPHostName = $hostName)) ) or
					($rewriteOnClass and contains(../@class, $rewriteOnClass))">
					<xsl:value-of select="$pageURL"/>
					<xsl:text>?tx_xmlinclude_xmlinclude[URL]=</xsl:text>
					<xsl:call-template name="url-encode">
						<xsl:with-param name="str" select="."/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>

		</xsl:attribute>
	</xsl:template>



	<!--
		Percent Escapes for ASCII.

		Taken from Mike J. Brown’s url-encode.xsl, available at
		http://skew.org/xml/stylesheets/url-encode/url-encode.xsl
	-->
	<xsl:template name="url-encode">
		<xsl:param name="str"/>
		<xsl:variable name="ascii"> !"#$%&amp;'()*+,-./0123456789:;&lt;=&gt;?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~</xsl:variable>
		<!-- Characters that usually don't need to be escaped -->
		<xsl:variable name="safe">!'()*-.0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~</xsl:variable>
		<xsl:variable name="hex" >0123456789ABCDEF</xsl:variable>

		<xsl:if test="$str">
			<xsl:variable name="first-char" select="substring($str,1,1)"/>
			<xsl:choose>
				<xsl:when test="contains($safe,$first-char)">
					<xsl:value-of select="$first-char"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="codepoint">
						<xsl:choose>
							<xsl:when test="contains($ascii,$first-char)">
								<xsl:value-of select="string-length(substring-before($ascii,$first-char)) + 32"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:message terminate="no">Warning: string contains a character that is out of range! Substituting "?".</xsl:message>
								<xsl:text>63</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
				<xsl:variable name="hex-digit1" select="substring($hex,floor($codepoint div 16) + 1,1)"/>
				<xsl:variable name="hex-digit2" select="substring($hex,$codepoint mod 16 + 1,1)"/>
				<xsl:value-of select="concat('%',$hex-digit1,$hex-digit2)"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="string-length($str) &gt; 1">
				<xsl:call-template name="url-encode">
					<xsl:with-param name="str" select="substring($str,2)"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>