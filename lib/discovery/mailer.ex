defmodule Discovery.Mailer do
  use Bamboo.Mailer, otp_app: :discovery
end

# Define your emails
defmodule Discovery.Email do
  import Bamboo.Email

  def welcome_email do
    new_email
    |> to("me@darrellpappa.com")
    |> from("support@alphaity.io")
    |> subject("Discovery - Invitation")
    |> html_body("You have been invited to join \"Company_Name\" in Discovery. Click this link to join!")
  end
end
