defmodule Discovery.Mailer do
  use Bamboo.Mailer, otp_app: :discovery
end

# Define your emails
defmodule Discovery.Email do
  import Bamboo.Email

  def welcome_email do
    new_email
    |> to("me@darrellpappa.com.com")
    |> from("alphaity@alphaity.io")
    |> subject("Welcome!!!")
    |> html_body("<strong>Welcome</strong>")
    |> text_body("welcome")
  end
end
