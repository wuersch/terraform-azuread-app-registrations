environment = "dev"

backends = {
  capacity-flow = {
    app_name           = "CapacityFlow"
    create_role_groups = true
    app_roles = {
      admin = {
        display_name = "Admin"
        description  = "Administrative access"
      }
      manager = {
        display_name = "Manager"
        description  = "Manager access for demand planning"
      }
      user = {
        display_name = "User"
        description  = "Standard user access"
      }
      viewer = {
        display_name = "Viewer"
        description  = "Read-only access"
      }
    }
    owners = ["74394094-86a6-46ed-b6c8-39e79a6ae81b"]
  }
}

spas = {
  capacity-flow-web = {
    app_name      = "CapacityFlow"
    backend       = "capacity-flow"
    redirect_uris = ["http://localhost:5173/"]
    owners = ["74394094-86a6-46ed-b6c8-39e79a6ae81b"]
  }
}
