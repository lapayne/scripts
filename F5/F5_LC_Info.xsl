<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/">
  <html>
  <body>
    <h2>Link Controller WideIP's</h2>
    <table border="1">
      <tr bgcolor="#9acd32">
        <th>Wide IP</th>
        <th>Virtual Servers</th>
		
      </tr>
      <xsl:for-each select="device/wideip">
        <tr>
          <td><xsl:value-of select="wideipname"/></td>

          		  <td>
		  
			  <table border="1">
				<tr bgcolor="#9acd32">
					<th>VS IP</th>
					<th>VS Port</th>
					<th>Pool</th>
					<th>Pool Members</th>
					<th>iRules</th>
				</tr>
				
				<xsl:for-each select="vss/vs">
					<tr>
						<td><xsl:value-of select="vsip"/></td>
						<td><xsl:value-of select="vsport"/></td>
						<td><xsl:value-of select="vspool"/></td>
					<td>
					 <table border="1">
				<tr bgcolor="#9acd32">
					<th>Pool Member Name</th>
					<th>Pool Member port</th>
					</tr>
						<xsl:for-each select="poolmembers/poolmember">
						<tr>
						<td><xsl:value-of select="poolmembername"/></td>
						<td><xsl:value-of select="poolmemberport"/></td>
						</tr>
						</xsl:for-each>
						
						</table>
					</td>
					<td><xsl:value-of select="irules"/></td>
					</tr>
				</xsl:for-each>
			  </table>
		  
		  </td>
		  
        </tr>
      </xsl:for-each>
    </table>
  </body>
  </html>
</xsl:template>

</xsl:stylesheet> 