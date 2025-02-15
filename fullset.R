```{r}
load("C:/Users/CMPERE2/Downloads/raw_norm_combat_seq.RData")
load("C:/Users/CMPERE2/Downloads/PFAS_Placenta_RNAseq.RData")
library("WGCNA")
library("tidyverse")
combat.adj = t(combat.adj)
```

```{r}
powers=seq(from=2,to=20,by=1) 
sft_pearson=pickSoftThreshold(combat.adj,RsquaredCut = 0.90, powerVector=powers, networkType ="signed", moreNetworkConcepts=T)
sft_pearson[["powerEstimate"]]
pst = sft_pearson[["fitIndices"]]

cex1=1.1
cex.axis=1.5
cex.lab=1.5
cex.main=1.5 
par(mfrow=c(2,2));
plot(powers,-sign(pst[,3])*pst[,2],type="n",
     xlab="Soft Threshold",
     ylab="SFT,signed Rˆ2",cex.axis=cex.axis, cex.main=cex.main, cex.lab=cex.lab, main="Scale Free Fit Index Rˆ2");
text(powers,-sign(pst[,3])*pst[,2], labels=powers,cex=cex1,col="red")
# this line corresponds to using an Rˆ2 cut-off of h 
abline(h=0.95,col="red")
plot(powers,pst$Density,
     type="n", xlab="Soft Threshold",ylab="Density", cex.axis=cex.axis, cex.main=cex.main,cex.lab=cex.lab, main="Density") 
text(powers,pst$Density,labels=powers,cex=cex1,col="red") 
plot(powers,pst$Heterogeneity,type="n",xlab="Soft Threshold", ylab="Heterogeneity",cex.main=cex.main, cex.lab=cex.lab, cex.axis=cex.axis, main="Heterogeneity") 
text(powers,pst$Heterogeneity,labels=powers,cex=cex1,col="red") 
plot(powers,pst$Centralization,type="n",xlab="Soft Threshold", ylab="Centralization",cex.axis=cex.axis, cex.main=cex.main, cex.lab=cex.lab, main="Centralization") 
text(powers, pst$Centralization, labels=powers,cex=cex1, col="red")
```

#Biweight Mid correlation
```{r}
powers = 1:20
#Call the network topology analysis function
#Analysis of scale free topology for multiple hard thresholds
sft_bicor = pickSoftThreshold(data = combat.adj, RsquaredCut = 0.90, dataIsExpr = T, powerVector = powers,networkType ="signed", corFnc="bicor" )
# Plot the results:
sizeGrWindow(9, 5)
par(mfrow = c(1,2));
cex1 = 0.9;
# Scale-free topology fit index as a function of the soft-thresholding power
plot(sft_bicor$fitIndices[,1], -sign(sft_bicor$fitIndices[,3])*sft_bicor$fitIndices[,2],
     xlab="Soft Threshold (power)",ylab="Scale Free Topology Model Fit,signed R^2",type="n",
     main = paste("Scale independence"));
text(sft_bicor$fitIndices[,1], -sign(sft_bicor$fitIndices[,3])*sft_bicor$fitIndices[,2],
     labels=powers,cex=cex1,col="red");
# this line corresponds to using an R^2 cut-off of h
abline(h=0.90,col="red")
# Mean connectivity as a function of the soft-thresholding power
plot(sft_bicor$fitIndices[,1], sft_bicor$fitIndices[,5],
     xlab="Soft Threshold (power)",ylab="Mean Connectivity", type="n",
     main = paste("Mean connectivity"))
text(sft_bicor$fitIndices[,1], sft_bicor$fitIndices[,5], labels=powers, cex=cex1,col="red")
```
#Spearman Correlation
```{r}
powers = 1:20
#Call the network topology analysis function
#Analysis of scale free topology for multiple hard thresholds
sft_spearman = pickSoftThreshold(data = combat.adj, RsquaredCut = 0.90, dataIsExpr = T, powerVector = powers,networkType ="signed", corFnc="cor", corOptions = list(method = "spearman"))
# Plot the results:
sizeGrWindow(9, 5)
par(mfrow = c(1,2));
cex1 = 0.9;
# Scale-free topology fit index as a function of the soft-thresholding power
plot(sft_spearman$fitIndices[,1], -sign(sft_spearman$fitIndices[,3])*sft_spearman$fitIndices[,2],
     xlab="Soft Threshold (power)",ylab="Scale Free Topology Model Fit,signed R^2",type="n",
     main = paste("Scale independence"));
text(sft_spearman$fitIndices[,1], -sign(sft_spearman$fitIndices[,3])*sft_spearman$fitIndices[,2],
     labels=powers,cex=cex1,col="red");
# this line corresponds to using an R^2 cut-off of h
abline(h=0.90,col="red")
# Mean connectivity as a function of the soft-thresholding power
plot(sft_spearman$fitIndices[,1], sft_spearman$fitIndices[,5],
     xlab="Soft Threshold (power)",ylab="Mean Connectivity", type="n",
     main = paste("Mean connectivity"))
text(sft_spearman$fitIndices[,1], sft_spearman$fitIndices[,5], labels=powers, cex=cex1,col="red")
```

#Building a Network with WGCNA 
```{r}
ADJ1=abs(cor(combat.adj,use="p"))^11
# When you have a lot of genes use the following code
k=softConnectivity(datE=combat.adj,power=11)
# Plot a histogram of k and a scale free topology plot
sizeGrWindow(10,5)
par(mfrow=c(1,2))
hist(k)
scaleFreePlot(k, main="Check scale free topology\n")
dissTOM=TOMdist(ADJ1)
```


#Module definition using the topological overlap based dissimilarity
```{r}
 #Calculate the dendrogram height 
hierTOM = hclust(as.dist(dissTOM),method="average");
# The reader should vary the height cut-off parameter h1
# (related to the y-axis of dendrogram) in the following
colorStaticTOM = as.character(cutreeStaticColor(hierTOM, cutHeight=.99, minSize=20))
colorDynamicTOM = labels2colors (cutreeDynamic(hierTOM,method="tree"))
colorDynamicHybridTOM = labels2colors(cutreeDynamic(hierTOM, distM= dissTOM , cutHeight = 0.99,
                     deepSplit=2, pamRespectsDendro = FALSE))
# Now we plot the results
sizeGrWindow(10,5)
plotDendroAndColors(hierTOM,
             colors=data.frame(colorStaticTOM,
                              colorDynamicTOM, colorDynamicHybridTOM),
             dendroLabels = FALSE, marAll = c(1, 8, 3, 1),
             main = "Gene dendrogram and module colors, TOM dissimilarity")
```
#KEGG biological pathway interpretation for modules 
#EnrichR
```{r}
df_colorDynamicHybridTOM = data.frame(colorDynamicHybridTOM,colnames(combat.adj))
table(df_colorDynamicHybridTOM$colorDynamicHybridTOM)
```

#top hub gene
```{r}
top_hub = chooseTopHubInEachModule(
   combat.adj, 
   colorDynamicHybridTOM, 
   omitColors = "grey", 
   power = 2, 
   type = "signed")
```

```{r}
TOM = TOMsimilarityFromExpr(combat.adj, power = 11)
modules = "grey60"
# Select module probes
probes = colnames(combat.adj)
inModule = is.finite(match(colorDynamicHybridTOM, modules))
modProbes = probes[inModule]
# Select the corresponding Topological Overlap
modTOM = TOM[inModule, inModule]
dimnames(modTOM) = list(modProbes, modProbes)
# Export the network into edge and node list files Cytoscape can read
cyt_turquoise_dynamicTOM = exportNetworkToCytoscape(modTOM,
  edgeFile = paste("CytoscapeInput-edges-", paste(modules, collapse="-"), ".txt", sep=""),
  nodeFile = paste("CytoscapeInput-nodes-", paste(modules, collapse="-"), ".txt", sep=""),
  weighted = TRUE,
  threshold = 0.02,
  nodeNames = modProbes,
  nodeAttr = colorDynamicTOM[inModule])
```

```{r}
module_Eigengenes_DynamicHybridTOM  = moduleEigengenes(expr = combat.adj, colors = df_colorDynamicHybridTOM$colorDynamicHybridTOM, impute = TRUE, nPC = 1, excludeGrey = TRUE)
```


```{r}
module_Eigengenes_DynamicHybridTOM_subset = module_Eigengenes_DynamicHybridTOM$eigengenes %>% rownames_to_column("ID") %>% filter(ID %in% pheno$ID) 
rownames(module_Eigengenes_DynamicHybridTOM_subset) = module_Eigengenes_DynamicHybridTOM_subset$ID
module_Eigengenes_DynamicHybridTOM_subset = module_Eigengenes_DynamicHybridTOM_subset[,-1]
pheno = pheno %>% filter(ID %in% rownames(module_Eigengenes_DynamicHybridTOM_subset)) %>% mutate(sum = rowSums(.[c("PFBSp","PFOSp","PFNAp","PFOAp","PFHxSp")]))
```

#PFAS and eigengenes 
```{r}
eigengene_color_PFAS = list()
PFASp = c("PFBSp","PFOSp","PFNAp","PFOAp","PFHxSp", "sum")
for (i in 1:40) {
  for (x in PFASp) {
     eigengene_color_PFAS[paste0(colnames(module_Eigengenes_DynamicHybridTOM_subset)[i],x)] = summary(lm(module_Eigengenes_DynamicHybridTOM_subset[,i] ~ pheno[,x]))$coefficients[2,4] 
  }
}

```


