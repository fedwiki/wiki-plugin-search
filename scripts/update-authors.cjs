const gitAuthors = require("grunt-git-authors");

// list of contributers from prior the split out of Smallest Federated Wiki repo.

gitAuthors.updatePackageJson({ order: "date" }, (error) => {
  if (error) {
    console.log("Error: ", error);
  }
});

gitAuthors.updateAuthors((error, filename) => {
  if (error) {
    console.log("Error: ", error);
  } else {
    console.log(filename, "updated");
  }
});
