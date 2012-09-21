url = 'http://api.openstreetmap.org/api/capabilities'

later = 'http://api.openstreetmap.org/api/0.6/map?bbox=-105,39.75,-104.9,40.25'
neighborhood = 'http://api.openstreetmap.org/api/0.6/map?bbox=-105.12074,39.98421,-105.09572,40.0092'
open = obj_new('MGnetRequest', url, debug=1)
r = open->get(response_header=h)
obj_destroy, open

end