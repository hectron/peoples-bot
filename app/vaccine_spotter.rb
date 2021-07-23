module VaccineSpotter
  States = [
    "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "DC", "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME",
    "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA",
    "PR", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY",
  ].freeze

  VaccineTypes = [
    Pfizer = "pfizer".freeze,
    Moderna = "moderna".freeze,
    JJ = "jj".freeze,
  ].freeze

  PrettyVaccineName = {
    Pfizer => "Pfizer".freeze,
    Moderna => "Moderna".freeze,
    JJ => "JJ".freeze,
  }
end
