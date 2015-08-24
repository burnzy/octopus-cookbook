describe "install_server recipe" {

  it "should install an octopus server instance" {
    $octopus = Invoke-RestMethod -Uri "http://localhost:80/api/"
    $packages.Count | should not be 0
    $packages[0].Title.InnerText | should be 'elmah'
  }

}
