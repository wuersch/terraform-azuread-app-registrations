environment = "dev"

backends = {
  myapp = {
    app_name           = "MyApp"
    create_role_groups = true
    # Uses default app_roles (user, viewer, admin)
    owners = [
      "74394094-86a6-46ed-b6c8-39e79a6ae81b", # TODO: Replace with primary owner object ID
      "6624c6f4-aaf0-423f-a544-4b152ef2bea3"  # TODO: Replace with deputy owner object ID
    ]
  }

  # Example: A shared service that other backends can call
  # shared-service = {
  #   app_name = "SharedService"
  #   app_roles = {
  #     service_read = {
  #       display_name         = "Service Read"
  #       description          = "Read access for backend services"
  #       allowed_member_types = ["Application"]  # Only applications can have this role
  #     }
  #     service_write = {
  #       display_name         = "Service Write"
  #       description          = "Write access for backend services"
  #       allowed_member_types = ["Application"]
  #     }
  #   }
  #   owners = [
  #     "00000000-0000-0000-0000-000000000000",
  #     "11111111-1111-1111-1111-111111111111"
  #   ]
  # }

  # Example: A backend that calls the shared service
  # caller-backend = {
  #   app_name = "CallerBackend"
  #   target_backends = {
  #     shared-service = {
  #       roles = ["service_read", "service_write"]  # Roles to request
  #     }
  #   }
  #   owners = [
  #     "00000000-0000-0000-0000-000000000000",
  #     "11111111-1111-1111-1111-111111111111"
  #   ]
  # }
}

spas = {
  myapp-web = {
    app_name      = "MyApp"
    backend       = "myapp"
    redirect_uris = ["https://myapp.omnom.ch/myapp"]
    owners = [
      "74394094-86a6-46ed-b6c8-39e79a6ae81b", # TODO: Replace with primary owner object ID
      "6624c6f4-aaf0-423f-a544-4b152ef2bea3"  # TODO: Replace with deputy owner object ID
    ]
  }
}
