network_info = {
  vpccidr = "10.0.0.0/16"
  vpcname = "provisinorvpc"
  pubsub = [{
    pubcidr = ["10.0.0.0/24", "10.0.1.0/24"]
    pubaz   = ["ap-south-1a", "ap-south-1b"]
    pubname = ["pub1", "pub2"]
  }]
  prsub = [{
    prcidr = ["10.0.2.0/24", "10.0.3.0/24"]
    praz   = ["ap-south-1c", "ap-south-1a"]
    prname = ["pub3", "pub4"]
  }]
}