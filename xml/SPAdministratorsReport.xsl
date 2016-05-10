<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:date="http://exslt.org/dates-and-times">

	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="/">

		<html>
			<head>
				<!-- <link rel="stylesheet" href="../../SiteAssets/css/style.css" type="text/css" media="screen" /> -->
			</head>
			<body>
				<h1>Site Collection Administrators</h1>
				<table class="SharePointTable">
					<thead>
						<tr>
							<th>Site Collection</th>
							<th>Administrators</th>
						</tr>
					</thead>
					<tfoot>
						<tr>
							<td></td>
							<td></td>
						</tr>
					</tfoot>
					<tbody>
						<xsl:for-each select="//WebApplications">
							<!-- <xsl:sort select="fpnReferralActDDKAge" data-type="number" order="descending"/> -->
							<tr>
								<td><xsl:value-of select="@url"/></td>
								<td><xsl:value-of select="count(.)"/></td>
							</tr>
						</xsl:for-each>
					</tbody>
				</table>
			</body>
		</html>
	</xsl:template>

</xsl:stylesheet>
