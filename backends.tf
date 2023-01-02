terraform {
  cloud {
    organization = "ansiblewjenkins"

    workspaces {
      name = "wsansiblejenkins"
    }
  }
}