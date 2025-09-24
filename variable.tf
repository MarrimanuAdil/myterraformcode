variable "network_info" {
  type = object({
    vpccidr = string
    vpcname = string
    pubsub = list(object({
      pubcidr = list(string)
      pubaz   = list(string)
      pubname = list(string)
    }))
    prsub = list(object({
      prcidr = list(string)
      praz   = list(string)
      prname = list(string)
    }))
  })
}