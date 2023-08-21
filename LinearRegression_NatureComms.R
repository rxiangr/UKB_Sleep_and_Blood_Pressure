# Function to run the linear regression

## Linear regression unstratified ###
# with BMI 
xvariable <- c("age", "sex", "bmi", "smokingStatus", "alcoholIntake", "alcoholFreq", "qualification",  "employmentStatus", "depression", "PActivity", "township_index")

# without bmi 
xvariable <- xvariable[!xvariable == "bmi"]

# note modify the xvariable when running regresison with CRP
LinearReg_BP_CircadianMarker <- function(data,
                                         filtercolumn=NA,
                                         outcome_yvariable = "BP_systolic",
                                         xvariable_of_interest = "sleepLength",
                                         covariates = xvariable){

if(!is.na(filtercolumn) & filtercolumn =="yes"){
  data <- data %>% filter(!BPMedicine == "yes")
}

xvariable_and_covariates <- c(xvariable_of_interest, covariates)  
# run regression 
fit <- lm(as.formula(paste(outcome_yvariable," ~ ", paste(xvariable_and_covariates, collapse= "+"))), data=data)
#get confidence interval
con <- confint(fit) 
con <- confint(fit)   
con <- con[-1,] 
con <- apply(con, 2, function(x) round(x, 2))
# get coefficients
fit1 <- summary(fit)$coefficients
fit1 <- data.frame(fit1[-1,])
cols <- colnames(fit1)[1:3]
fit1 <- fit1 %>% mutate_at(cols, round, 3)
colnames(fit1) <- c("Estimate", "Std_Error", "t.value", "Pvalue")
con1 <- con[which(rownames(con) %in% rownames(fit1)),]
fit1 <- cbind(fit1, con1) 
fit1$Pvalue <- format(fit1$Pvalue, digits=3)
return(fit1)
}



## Linear regression stratified ###
stratified_group = "sex"
for(i in unique(data[stratified_group])){
data_sub <- data %>% filter(!!sym(stratified_group) == i)
  # remove the group being stratified
xvariable_sub <- xvariable[!xvariable == stratified_group]
xvariable_of_interest = "sleepLength"
dat <- LinearReg_BP_CircadianMarker(data_sub, 
                               filtercolumn = NA,
                               outcome_yvariable = "BP_systolic",
                               xvariable_of_interest = "sleepLengthC",
                               covariates = xvariable_sub)
dat <- dat %>% mutate(variables = rownames(dat)) %>% relocate(variables, .before=Estimate)
dat$group <- paste0(stratified_group, "_", i)
# additionally subset to xvariable_of_interest 
elements <- data_sub %>% dplyr::select(sym(xvariable_of_interest)) %>% mutate_if(is.factor, as.character) %>% distinct() %>% 
  pull()
dat1 <- dat %>% filter(variables %in% paste0(xvariable_of_interest,elements))
}  

  