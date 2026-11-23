# Aurora dependency licence review =======================

# Install if required
# install.packages("renv")

# Identify direct dependencies across the repository
direct_packages <- sort(unique(
  renv::dependencies(path = ".")$Package
))

# Exclude the auditing tool itself
direct_packages <- setdiff(direct_packages, "renv")

# Retrieve installed package metadata
ip <- installed.packages()

# Identify indirect (transitive) dependencies
indirect_packages <- tools::package_dependencies(
  packages = direct_packages,
  db = ip,
  which = c("Depends", "Imports", "LinkingTo"),
  recursive = TRUE
)

# Combine direct and indirect dependencies
all_packages <- sort(unique(c(
  direct_packages,
  unlist(indirect_packages)
)))

all_packages <- setdiff(all_packages, "R")

# Identify packages that are not installed
missing_packages <- setdiff(all_packages, rownames(ip))

print(missing_packages)

# Extract package versions and licences
licence_review <- data.frame(
  Package = all_packages,
  Version = ip[match(all_packages, rownames(ip)), "Version"],
  Licence = ip[match(all_packages, rownames(ip)), "License"],
  Dependency = ifelse(
    all_packages %in% direct_packages,
    "Direct",
    "Indirect"
  ),
  CRAN = paste0(
    "https://cran.r-project.org/package=",
    all_packages
  ),
  stringsAsFactors = FALSE
)

# View results
View(licence_review)

# Export results
write.csv(
  licence_review,
  "dependency_licences.csv",
  row.names = FALSE
)

# Record review environment
sessionInfo()