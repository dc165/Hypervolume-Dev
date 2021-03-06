\name{hypervolume_overlap_test}
\alias{hypervolume_overlap_test}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Null distribution for overlap statistics
}
\description{
Generates null distribution of four different overlap statistics under the null hypothesis that two samples are drawn from the same population.
Observed value of overlap statistic is calculated from inputed hypervolumes.
calculates p value for observed value of each statistic with respect to the generated null distributions.
}
\usage{
hypervolume_overlap_test(hv1, hv2, path, alternative = "one-sided", bins = 100, cores = 1)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{hv1}{
A hypervolume object
}
  \item{hv2}{
A hypervolume object
}
  \item{path}{
a path to a directory containing permuted hypervolumes, bootstrapped hypervolumes, or a vector of two paths to bootstrapped hypervolumes
}
  \item{alternative}{
"one-sided" or "two-sided"
}
  \item{bins}{
plotting parameter for histogram of overlap statistics
}
  \item{cores}{
Number of logical cores to use while generating overlap statistics. If parallel backend already registered to \code{doParallel}, function will use that backend and ignore the argument in cores.
}
}
\details{
Generating overlap statistics can be parallelized using the \code{cores} argument.  

hypervolume_overlap_test can generate a null distribution from the output of hypervolume_permute, hypervolume_resample with method = "bootstrap", or a vector of two bootstrap outputs. See examples for how to use each case.

path should point to hypervolumes generated from the two input hypervolumes. There are three valid choices:

path is generated from \code{hypervolume_permute(<name>, hv1, hv2, ...)}. In this case the null distribution is generated by taking the overlap statistics of every single pair of permutations and turning them into a histogram.

OR

path is generated by resampling the hypervolume generated by combining the data of hv1 and hv2
If the number of data points used to generate hv1 is the same as hv2 then the path is \code{hypervolume_resample(<name>, hv_combined, "bootstrap", points_per_resample = nrow(hv1@Data))}. In this case, the list bootstrapped hypervolumes is split in half and overlap statistics are taken for every possible pair of hypervolumes from the two halves. A histogram of these overlap statitics represent the null distribution.

If the number of data points is different between hv1 and hv2 path is a list of two paths generated from \code{hypervolume_resample(<name>, hv_combined, "bootstrap", points_per_resample = nrow(hv1@Data), ...)} and \code{hypervolume_resample(<name>, hv_combined, "bootstrap", points_per_resample = nrow(hv2@Data), ...)}. Overlap statistics are taken for every possible pair of hypervolumes from each bootstrap. A histogram of these overlap statitics represent the null distribution.
See example for appropriate path inputs. 

The four overlap statistics are Sorensen, Jaccard, frac_unique_1, frac_unique_2. See \code{\link{hypervolume_overlap_statistics}} for description of the statistics.
}
\value{
  \item{p_values}{
a list of p_values indexed by the name of the relevant statistic
}
  \item{plots}{
a list of ggplot objects indexed by the name of the relevant statistic. The observed value of each statistic is represented as a dot on the x axis.
}
  \item{distribution}{
a matrix of overlap statistics used to generate the null distribution
}
}

\seealso{
\code{\link{hypervolume_resample}}, \code{\link{hypervolume_permute}}
}

\examples{
\dontrun{
# We will use the data in "quercus" as our population in this example
data("quercus")
# Consider taking two samples of size 150 from the population and you want to figure out whether
# the samples are similar by seeing if they occupy the same area in feature space.
qsample1 = quercus[sample(1:nrow(quercus), 150),]
qsample2 = quercus[sample(1:nrow(quercus), 150),]

# Construct two hypervolumes from the samples
hv1 = hypervolume(qsample1[,2:3])
hv2 = hypervolume(qsample2[,2:3])

# Approach 1
# Take 200 permutations of the 300 data points. Using more cores is faster.
perm_path = hypervolume_permute("Quercus_perm_150", hv1, hv2, n = 200, cores = 20)

# hypervolume_overlap_test takes perm_path as an input. 
# Results include p values for the overlap statistics of hv1 and hv2 as well as 
# the corresponding null distributions generated from perm_path.
results1 = hypervolume_overlap_test(hv1, hv2, perm_path, cores = 20)

# Approach 2
# Under our null hypothesis the samples come from the same population. 
# Approximate the original population by combining the data
# then simulate drawing 150 data points 50 times.
hv_combine = hypervolume(rbind(qsample1[,2:3],qsample2[,2:3]))
bootstrap_path = hypervolume_resample("Quercus_boot_150", 
                                        hv_combine, 
                                        method = "bootstrap", 
                                        n = 50, 
                                        points_per_resample = 150, 
                                        cores = 20)

# hypervolume_overlap_test splits the 50 resampled hypervolumes in half and gets
# overlap statistic for each of the 25*25 pairs to generate the null 
# distribution. This method allows us to approximate the null distribution using
# 625 data points while only generating 50 hypervolumes as opposed to 
# hypervolume_permute which uses 400 hypervolumes to generate 200 data points.
results2 = hypervolume_overlap_test(hv1, hv2, bootstrap_path)

# Approach 3
# Suppose we have a size 300 sample and a size 150 sample and we want to know 
# whether they come from the same distribution.
qsample3 = quercus[sample(1:nrow(quercus), 300),]
hv3 = hypervolume(qsample3[,2:3])

# Permutation still works in this case, however we can also use bootstrap by 
# combining the data and drawing size 150 then size 300 samples.
hv_combine = hypervolume(rbind(qsample1[,2:3],qsample3[,2:3]))
b150_path = resample("Quercus_150", 
                      hv_combine, 
                      method = "bootstrap", 
                      n = 25, 
                      points_per_resample = 150, 
                      cores = 20)
b300_path = resample("Quercus_300", 
                      hv_combine, 
                      method = "bootstrap", 
                      n = 25, 
                      points_per_resample = 300, 
                      cores = 20)

# hypervolume_overlap_test generates overlap statistics for each of the 25*25 
# possible pairs of size 150 and size 300 hypervolumes.
results3 = hypervolume_overlap_test(hv1, hv2, c(b150_path, b300_path), cores = 1)
}
}
