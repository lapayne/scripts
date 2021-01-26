<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/">
  <html>
  <body>
    <h2>F5 VIPS</h2>
    <table border="1">
      <tr bgcolor="#9acd32">
        <th>Virtual Server</th>
        <th>IP</th>
		<th>Port</th>
		<th>Partition</th>
		<th>State</th>
		<th>Default pool</th>
		<th>VS Type</th>
		<th>Persistence</th>
		<th>Fallback Persistence</th>
		<th>VLAN</th>
		<th>Protocol</th>
		<th>Client Protocol profile</th>
		<th>Server protocol Profile</th>
		<th>HTTP Profile</th>
		<th>Compression Profile</th>
		<th>Acceleration profile</th>
		<th>Client SSL profile</th>
		<th>Server SSL profile</th>
		<th>SNAT pool</th>
		<th>iRules</th>
		<th>Pool members</th>
      </tr>
      <xsl:for-each select="device/virtual_server">
        <tr>
          <td><xsl:value-of select="name"/></td>
          <td><xsl:value-of select="vip"/></td>
		  <td><xsl:value-of select="vip_port"/></td>
		  <td><xsl:value-of select="partition"/></td>
		  <td><xsl:value-of select="state"/></td>
		  <td><xsl:value-of select="default_pool"/></td>
		  <td><xsl:value-of select="vs_type"/></td>
		  <td><xsl:value-of select="default_persistance"/></td>
		  <td><xsl:value-of select="fallback_persistance"/></td>
		  <td><xsl:value-of select="vlan"/></td>
		  <td><xsl:value-of select="vs_protocol"/></td>
		  <td><xsl:value-of select="client_profile"/></td>
		  <td><xsl:value-of select="server_profile"/></td>
		  <td><xsl:value-of select="http_profile"/></td>
		  <td><xsl:value-of select="compression_profile"/></td>
		  <td><xsl:value-of select="acceleration_profile"/></td>
		  <td><xsl:value-of select="client_ssl"/></td>
		  <td><xsl:value-of select="server_ssl"/></td>	  
		  <td><xsl:value-of select="snat_pool"/></td>		  

		  		  <td>
		  
			  <table border="0">

				<td>
						<td><xsl:value-of select="irules"/></td>
				</td>
			  </table>
		  
		  </td>
	
 
		  <td>
		  
			  <table border="1">
				<tr bgcolor="#9acd32">
					<th>Pool Member Name</th>
					<th>Pool Member Port</th>
					<th>Pool Member Availability</th>
					<th>Pool Member Status</th>
				</tr>
				<xsl:for-each select="poolmembers/poolmember">
					<tr>
						<td><xsl:value-of select="poolmembername"/></td>
						<td><xsl:value-of select="poolmemberport"/></td>
						<td><xsl:value-of select="poolmember_availability"/></td>
						<td><xsl:value-of select="poolmember_status"/></td>
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