variable "project_id" { type = string }
variable "service_accounts" {
  type = map(object({
    display_name = string
    roles        = list(string)
  }))
}

resource "google_service_account" "sa" {
  for_each     = var.service_accounts
  account_id   = each.key
  display_name = each.value.display_name
}

resource "google_project_iam_member" "sa_role_per_binding" {
  for_each = {
    for pair in flatten([
      for k, v in var.service_accounts : [
        for r in v.roles : {
          sa   = k
          role = r
        }
      ]
    ]) : "${pair.sa}|${pair.role}" => pair
  }
  project = var.project_id
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.sa[each.value.sa].email}"
}

output "service_account_emails" {
  value = { for k, v in google_service_account.sa : k => v.email }
}
