require_relative 'client'

 cl = BrocadeAPI_client::Client.new('https://dcfm.office.orange.intra/rest')
 cl.login('radud','radud')
# radu2= cl.get_resourcegroups
#  puts "ressource groups #{radu2}"
#  radu= cl.get_fabric('10:00:50:EB:1A:A8:2C:54')
 radu3 = cl.get_fabrics
 puts "fabrics #{radu3}"
#  radu = cl.get_fabricswitches('10:00:00:27:F8:F7:61:00')
#  radu = cl.get_allswitches
# radu = cl.get_allports
# radu = cl.change_portstates('Fabric0-Farm1','10:00:88:94:71:71:B4:EC',['20:00:88:94:71:71:B4:EC','20:01:88:94:71:71:B4:EC'],'enable')
#  radu = cl.change_persistentportstates('Fabric0-Farm1','10:00:88:94:71:71:B4:EC',['20:00:88:94:71:71:B4:EC','20:01:88:94:71:71:B4:EC'],'enable')
#  radu = cl.set_portname('Fabric0-Farm1','10:00:88:94:71:71:B4:EC','20:01:88:94:71:71:B4:EC','vantivedbbuc-2.prod.orange.intra')
#   radu =  cl.get_allzonesinfabric('Fabric0-Farm1','10:00:00:27:F8:F7:61:00')
#  radu = cl.get_fabriczones_defined('Fabric0-Farm1','10:00:00:27:F8:F7:61:00')
# puts "resoursa #{radu}"
# cl.logout
