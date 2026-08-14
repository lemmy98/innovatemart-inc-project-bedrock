variable "name" {
  description = "Budget name."
  type        = string
}

variable "limit_usd" {
  description = "Monthly USD limit that triggers the email alert."
  type        = number
}

variable "notification_email" {
  description = "Email that receives the budget alert."
  type        = string
}

variable "project_tag" {
  description = "Project tag value used to scope the budget."
  type        = string
}
