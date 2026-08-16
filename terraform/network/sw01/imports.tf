# --- static routes ---

import {
  to = routeros_ip_route.gateway
  id = "comment=gateway"
}


# --- bridge ---

import {
  to = module.interfaces.routeros_interface_bridge.bridge
  id = "name=bridge"
}


# --- ethernets ---

import {
  to = module.interfaces.routeros_interface_ethernet.interfaces["ether1"]
  id = "name=ether1"
}

import {
  to = module.interfaces.routeros_interface_ethernet.interfaces["sfp-sfpplus1"]
  id = "name=sfp-sfpplus1"
}

import {
  to = module.interfaces.routeros_interface_ethernet.interfaces["sfp-sfpplus2"]
  id = "name=sfp-sfpplus2"
}

import {
  to = module.interfaces.routeros_interface_ethernet.interfaces["sfp-sfpplus3"]
  id = "name=sfp-sfpplus3"
}

import {
  to = module.interfaces.routeros_interface_ethernet.interfaces["sfp-sfpplus4"]
  id = "name=sfp-sfpplus4"
}

import {
  to = module.interfaces.routeros_interface_ethernet.interfaces["sfp-sfpplus5"]
  id = "name=sfp-sfpplus5"
}

import {
  to = module.interfaces.routeros_interface_ethernet.interfaces["sfp-sfpplus6"]
  id = "name=sfp-sfpplus6"
}

import {
  to = module.interfaces.routeros_interface_ethernet.interfaces["sfp-sfpplus7"]
  id = "name=sfp-sfpplus7"
}

import {
  to = module.interfaces.routeros_interface_ethernet.interfaces["sfp-sfpplus8"]
  id = "name=sfp-sfpplus8"
}


# --- bonds ---

import {
  to = module.interfaces.routeros_interface_bonding.bonds["sfpp[7-8]"]
  id = "name=sfpp[7-8]"
}


# --- bridge ports ---

import {
  to = module.interfaces.routeros_interface_bridge_port.interfaces["ether1"]
  id = "interface=ether1"
}

import {
  to = module.interfaces.routeros_interface_bridge_port.interfaces["sfp-sfpplus1"]
  id = "interface=sfp-sfpplus1"
}

import {
  to = module.interfaces.routeros_interface_bridge_port.interfaces["sfp-sfpplus2"]
  id = "interface=sfp-sfpplus2"
}

import {
  to = module.interfaces.routeros_interface_bridge_port.interfaces["sfp-sfpplus3"]
  id = "interface=sfp-sfpplus3"
}

import {
  to = module.interfaces.routeros_interface_bridge_port.interfaces["sfp-sfpplus4"]
  id = "interface=sfp-sfpplus4"
}

import {
  to = module.interfaces.routeros_interface_bridge_port.interfaces["sfp-sfpplus5"]
  id = "interface=sfp-sfpplus5"
}

import {
  to = module.interfaces.routeros_interface_bridge_port.interfaces["sfp-sfpplus6"]
  id = "interface=sfp-sfpplus6"
}

#import {
#  to = module.interfaces.routeros_interface_bridge_port.interfaces["sfp-sfpplus7"]
#  id = "interface=sfp-sfpplus7"
#}
#
#import {
#  to = module.interfaces.routeros_interface_bridge_port.interfaces["sfp-sfpplus8"]
#  id = "interface=sfp-sfpplus8"
#}

import {
  to = module.interfaces.routeros_interface_bridge_port.bonds["sfpp[7-8]"]
  id = "interface=sfpp[7-8]"
}


# --- bridge (l2) vlans ---

import {
  to = module.interfaces.routeros_interface_bridge_vlan.vlans["mgmt"]
  id = "comment=mgmt"
}

import {
  to = module.interfaces.routeros_interface_bridge_vlan.vlans["ceph-cluster"]
  id = "comment=ceph-cluster"
}

import {
  to = module.interfaces.routeros_interface_bridge_vlan.vlans["ceph-public"]
  id = "comment=ceph-public"
}

import {
  to = module.interfaces.routeros_interface_bridge_vlan.vlans["hosts"]
  id = "comment=hosts"
}


# --- interface (l3) vlans / svis ---

import {
  to = module.interfaces.routeros_interface_vlan.svi_vlans["mgmt"]
  id = "name=mgmt"
}

import {
  to = module.interfaces.routeros_ip_address.svi_vlans["mgmt"]
  id = "interface=mgmt"
}
