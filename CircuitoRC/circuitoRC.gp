reset session
$data1 << EOD
 0.0 1.5686159179138452
 2.0e-5 1.33500106673234
 4.0e-5 1.0986122886681098
 6.0e-5 0.8754687373538999
 8.0e-5 0.6418538861723947
 0.0001 0.43825493093115514
 0.00012 0.1823215567939544
 0.00014 0.0
 0.00016 -0.22314355131421
 0.00018 -0.5108256237659913
 0.0002 -0.6931471805599453
 0.00022 -0.9162907318741564
 0.00024 -1.2039728043259366
 0.00026 -1.3862943611198906
 0.00028 -1.6094379124340994
EOD
$data2 << EOD
 0.0 1.5686159179138452
 2.0e-5 1.33500106673234
 4.0e-5 1.0647107369924282
 6.0e-5 0.8329091229351039
 8.0e-5 0.587786664902119
 0.0001 0.3364722366212129
 0.00012 0.1823215567939544
 0.00014 -0.1053605156578264
 0.00016 -0.3566749439387321
 0.00018 -0.5978370007556207
 0.0002 -0.9162907318741564
 0.00022 -1.0498221244986787
 0.00024 -1.2039728043259366
 0.00026 -1.6094379124340994
EOD
plot  \
  $data1 w l, \
  $data2 w l
set output