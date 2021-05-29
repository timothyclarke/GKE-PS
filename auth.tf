provider "google" {
  credentials = file("paymentsense-315208-ace9a2046ece.json")
}
provider "google-beta" {
  credentials = file("paymentsense-315208-ace9a2046ece.json")
}
