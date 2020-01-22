# Master-servers' protocol

Master-server's message formatting: `"<message_code, 1 byte><payload>"`

## Message codes

```
-- Client message codes -> to Master
local INIT = 1 -- initial connection, send username
local FIND = 2 -- send lobby's / other player's fullname

-- Master message codes -> to Client
local FLUSH = 1 -- leave lobby, drop all 
local JOIN = 2  -- found lobby / player, connect to it
```


## Payloads

<table class="info-table">
<tr>
<th>Message</th>
<th>Payload</th>
</tr>
<tr>
<td>Client.INIT</td>
<td><code>"&lt;public_ip, string&gt;;&lt;username, string&gt;"</code></td>
</tr>
<tr>
<td>Client.FIND</td>
<td><code>"&lt;username, string&gt;"</code></td>
</tr>
<tr>
<td>Master.JOIN</td>
<td><code>"&lt;p1_ip&gt;;&lt;p2_name&gt;;&lt;p2_public_ip&gt;;&lt;p2_ip&gt;"</code></td>
</tr>
<tr>
<td>Master.FLUSH</td>
<td><code>no payload</code></td>
</tr>
</table>

`p1_ip` is used to determine if players is under one NAT and avoid hairpinning problems.
