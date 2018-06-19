#file reading library
fs = require "fs"
openstack = (file = "./config/os_env.json") ->
  #try to parse the json file
  os_str = fs.readFileSync(file).toString().trim()

  #env_obj = Object.create(process.env)
 
  #create a map object with string:environment objects
  map = {}
  try
    supported = JSON.parse(os_str)
    #loop through the supported environments in JSON file
    for k, v of supported
    #assign string key to an environment object
      map[k] = Object.create(process.env)
      #loop through the variables of this environment
      for env_k, env_v of supported[k]
        #add these values to the environment object
        map[k][env_k] = env_v

  catch
    throw new Error("Unable to parse your os_env.json file")
  map

#export apps and be able to import it in another file
module.exports = {
  openstack:openstack
}
