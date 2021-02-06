# Controller
controller_ip = ""
username      = "admin"
password      = ""

# Access
# Set below to false if you deployed the controller by provided TF or want to use own key
create_key    = false         # Provide existing key name below if set to false
key_name      = "cloudN-demo" # If you created a key in the controller TF, the key name will be "cloudN-demo"
ssh_addresses = []            # IP addresses allowed to access cloud infrastructure, format ["x.x.x.x/yy,"z.z.z.z/qq"]