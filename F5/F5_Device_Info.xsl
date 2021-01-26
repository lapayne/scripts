<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:param name="soe" select="document('SOE.xml')"/>
<xsl:template match="/">
	<html>
		<body>
			<h2>Device Data</h2>
			<table border="1">
				<tr bgcolor="#9acd32">
				<th>Device Name</th>
				<th>Region</th>
				<th>Licensed Features</th>
				<th>Platform</th>
				<th>Software version</th>
				<th>LACP Trunk</th>
			</tr>
	    
			<xsl:for-each select="configurations/device">
			<tr>
				<td><xsl:value-of select="devicename"/></td>
				<td><xsl:value-of select="region"/></td>
				<td><xsl:value-of select="licensedfeatures"/></td>
				<td><xsl:value-of select="platform"/></td>
		
		<!--Checks if the software version is the current SOE version as defined-->		
				<xsl:choose>
					<xsl:when test="contains(swver, $soe/device/swver)">
						<td bgcolor="#00FF40"><xsl:value-of select="swver"/></td>
					</xsl:when>
					<xsl:otherwise>
						<td bgcolor="#FF0000"><xsl:value-of select="swver"/></td>
					</xsl:otherwise>          
				</xsl:choose>
		  
		  <!--Checks if a trunk is configured on a LC-->
				<xsl:choose>
					<xsl:when test="contains(licensedfeatures, 'LC')">
						<xsl:choose>
						<xsl:when test="contains(trunk, $soe/device/trunk)">
							<td bgcolor="#FF0000"><xsl:value-of select="trunk"/></td>
						</xsl:when>
					<xsl:otherwise>
						<td bgcolor="#00FF40"><xsl:value-of select="trunk"/></td>
					</xsl:otherwise>          
				</xsl:choose>
			</xsl:when>

				<!--If it's not a link controller invert the colours to display correctly-->
			<xsl:otherwise>
				<xsl:choose>
			<xsl:when test="contains(trunk, $soe/device/trunk)">
				<td bgcolor="#00FF40"><xsl:value-of select="trunk"/></td>
			</xsl:when>
			<xsl:otherwise>
				<td bgcolor="#FF0000"><xsl:value-of select="trunk"/></td>
			</xsl:otherwise>          
		</xsl:choose>
		</xsl:otherwise>          
	</xsl:choose>
        </tr>
      </xsl:for-each>
    </table>
  </body>
  </html>
</xsl:template>

</xsl:stylesheet> 