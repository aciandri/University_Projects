################################
#### DATA MINING - FUNZIONI ####
################################

##### FUNZIONI PER PULIZIA DATI #####

## Missing
NA_fun = function(data){
  n_NA = sapply(data, function(col) sum(is.na(col)))
  n_NA = sort(n_NA[n_NA > 0])
  n_NA = data.frame(
    variabile = names(n_NA),
    freq_assoluta = as.numeric(n_NA),
    freq_relativa = round(as.numeric(n_NA)/nrow(data), 4)
  )
  n_NA }

#controllo l'ordinamento del dataset per data
ordinati_x_data <- function(DF, date_column) {
  if (!(date_column %in% colnames(DF))) {
    stop("La colonna della data specificata non è presente nel dataset.")
  }
  dati_ordinati <- DF[order(DF[[date_column]]), ]
  date_ordinate <- na.omit(dati_ordinati[[date_column]])
  date_DS <- na.omit(DF[[date_column]])
  if (all(date_ordinate==date_DS)) {
    cat("Le osservazioni sono ordinate per data (a meno degli NA).\n")
  } else {
    cat("Le osservazioni NON sono ordinate per data (a meno degli NA).\n")
  }
}

# date (imputazione sicura)
miss_date = function(df = dati, date = 'date'){
  i = 1 # indicatore di riga
  ind1 = c() # contiene l'ultima osservazione prima di NA quando dati problematici
  ind2 = c() # contiene la prima osservazione prima di NA quando dati problematici
  diff = c() # contiene le differenze tra le due pointer per dati problematici
  n_na = c() # contiene il numero di missing tra le 2 pointer
  n2 = 0 # numero na risolti
  id_data = which(colnames(df) == date)
  
  while (i <= nrow(df)){
    #  print(i)
    pointer2 = i
    if(i == 1) pointer1 = i # prima riga pointer1 = 1
    if( i != 1){
      if(!is.na(df[i, id_data])) {pointer1 = i }# primo record diverso da NA => pointer1 = i
      else {
        j = 0 # numero di record dopo i che sono NA
        while(is.na(df[i+j, id_data]) ) {
          j = j+1 # quanti record ci sono dopo il primo NA
        }
        pointer2 = i+j # primo record diverso da NA dopo una serie di NA
        if(df[pointer1, id_data] == df[pointer2, id_data] ) {
          df[pointer1:pointer2, id_data] = df[pointer1, id_data] 
          n2 = n2+1
        }
        # se le due pointer (ultima data non NA prima degli NA e prima data non NA dopo la serie di NA) 
        # sono uguali => le date mancanti nel mezzo saranno pari alle due pointer
        else {
          ind1 = c(ind1, pointer1)
          ind2 = c(ind2, pointer2)
          #print(cbind(pointer1, dati$data[pointer1]))
          #print(cbind(pointer2, dati$data[pointer2]))
          diff = c(diff,df[pointer2, id_data]- df[pointer1, id_data])
          n_na = c(n_na, pointer2-pointer1)
          print(diff)
        }
      }
    }
    i = pointer2+1
  }
  return(data.frame(pointer1 = df[ind1,id_data ], pointer2 = df[ind2, id_data], num_NA = n_na, giorni = diff))
  
  
}
miss_mese = function(df = dati, mese = 'mese', flag = F){ # flag = F mette tutti al mese prima ; flag = T mette tutti al mese dopo
  i = 1 # indicatore di riga
  indicat1 = c() # contiene l'ultima osservazione prima di NA quando dati problematici
  indicat2 = c() # contiene la prima osservazione prima di NA quando dati problematici
  idmese = which(colnames(dati) == mese)
  
  while (i <= nrow(df)){
    #  print(i)
    pointer2 = i
    if(i == 1) pointer1 = i # prima riga pointer1 = 1
    if( i != 1){
      if(!is.na(df[i,idmese])) {pointer1 = i }# primo record diverso da NA => pointer1 = i
      else {
        j = 0 # numero di record dopo i che sono NA
        while(is.na(df[i+j, idmese]) ) {
          j = j+1 # quanti record ci sono dopo il primo NA
        }
        pointer2 = i+j # primo record diverso da NA dopo una serie di NA
        if(df[pointer1, idmese] - df[pointer2, idmese] < 2) {
          if(flag)df[pointer1:pointer2, idmese] = df[pointer2, idmese]
          else{df[pointer1:pointer2, idmese] = df[pointer1, idmese]}
          } 
        # se le due pointer (ultima data non NA prima degli NA e prima data non NA dopo la serie di NA) 
        # sono uguali => le date mancanti nel mezzo saranno pari alle due pointer
        else {
          indicat1 = c(indicat1, pointer1)
          indicat2 = c(indicat2, pointer2)
          #print(cbind(pointer1, dati$data[pointer1]))
          #print(cbind(pointer2, dati$data[pointer2]))
        }
      }
    }
    i = pointer2+1
  }
  return(df)
}
# dati = miss_mese()

## Costanti ####
costanti = function(data = dati,cost = F){
  n = 0
  costant = c()
  for (el in colnames(data)){
    if (length(unique(data[,el])) == 1){ 
      if(cost == T)  data = data[,-which(colnames(data) == el)]
      costant = c(costant, el)
      n = n+1
    } }
  print(n)
  if(cost) return(data)
  return(costant)
}

qualquant = function(df = dati, y = "y", numero = 6, flag = F, quant = c()){
  idY = which(colnames(df) == y)
  if(length(quant) == 0){
    tipo = c()
    for (nome in colnames(df [,-idY])){ 
      if (is.numeric(df[, nome])){quant = c(quant, nome)} 
      else{
        # qual = c(qual, nome)
        if(is.character(df[, nome])){ tipo = c(tipo, 'character') }
        else{ tipo = c(tipo, 'factor')}
      }
    }
    print(tipo)
  }
  
  ## Controllo variabili quantitative da mettere a qualitative
  n = 0
  qq = c() # variabili da quant a qual
  for (el in quant){
    
    #if(dim(table(df[,el])) != 2){ print(el)}
    #if(dim(table(df[,el]) == 2)){ n = n+1}
    #df[,el] = factor(df[,el])
    if (dim(table(df[,el]))[1] < numero){
      #print(unique(df[,el]))
      #df[,which(colnames(df) == el) ] = factor(df[,which(colnames(df) == el)])
      #quant = quant[-which(quant == el)]
      qq = c(qq, el)
      n = n+1
    }
  }
  #table(df$X19)
  print(paste('Numero quantitative a qualitative:', n))
  print('Variabili quantitative a qualitative:')
  print(qq)
  if(flag) return (qq, quant)
  return(quant)
}
#qual = setdiff(colnames(dati), quant)

## Categorie rare ####
rari2 <- function(df, num = 10) {
  rari  = df %>%
    select_if(is.factor) %>%
    keep(~ any(table(.) < num)) %>%
    map(~ levels(.)[table(.) < num])
  
  df_result <- map_df(names(rari), ~ data.frame(variabile = .x, livello_raro = unlist(rari[[.x]])))
  tab = table(df_result$variabile)
  for (i in 1:length(tab)){
    print(length(tab) - i)
    if(length(unique(df[,names(tab[i])])) == 2) df_result[df_result$variabile == names(tab[i]), 'Soluzione'] = '2 Livelli'
    else{
      if (tab[i] == 1)  df_result[df_result$variabile == names(tab[i]), 'Soluzione'] = 'Raro'
      else{  df_result[df_result$variabile == names(tab[i]), 'Soluzione'] = 'Aggrega'}
    }
  }
  return(df_result)
}


rari = function(dati = dati, qual = qual, num = 10, cambia = F, nuovo_nome = 'Altro'){
  rare = data.frame(Variabile = c(0), Livello = c(0), Osservazioni = c(0), Nuovo_livello = c(0)) # contiene quello che cambiamo o che va cambiato
  i = 1 # indicatore riga rare
  
  for(variabile in qual){ # per ogni qualitativa
    print(variabile)
    for(el in unique(dati[,variabile])){ # per ogni livello della qualitativa
      print(nrow(dati[dati[,variabile] == el,]))
      if(nrow(dati[dati[,variabile] == el,]) < num) { # se il numero di volte in cui si osserva il livello < num
        rare[i,] = c(variabile, el,nrow(dati[dati[,variabile] == el,]),  NA) # si aggiunge a rare
        print(el)
        i = i+1
      }
    }
    if (nrow(rare[rare$Variabile == variabile, ]) > 1) { # se ci sono più valori rari, magari li possiamo accorpare in un nuovo livello
      rare[rare$Variabile == variabile, 4] = 'raro'
    }
    else{
      if(length(unique(dati[,variabile])) == 2) rare[rare$Variabile == variabile, 4] = '2 livelli'
    }
  }
  
  #print(paste('unique(rare[,1])', list(unique(rare[,1]))))
  #print(unique(rare[,1]))
  if(cambia){ # controllare prima che non siano ordinate
    dd = dati
    for(variabile in unique(rare[,1])){
      # print(variabile)
      if(!is.character(dd[,variabile])) dd[,variabile] = as.character(dd[,variabile])
      dd[ dd[,variabile] %in% (rare[rare$Variabile == variabile, 2]),variabile] = nuovo_nome
      print(paste('ok', variabile))
      dd[,variabile] = factor(dd[,variabile])
    }
    return(dd)
  }
  return(rare)
}

## Correlazione x quantitativa e y qualitativa ####
eta2 <- function(x,y){ #x variabile quantitativa, y variabile qualitativa. Per corr
  m <- mean(x,na.rm = TRUE)
  sct <- sum((x-m)^2,na.rm = TRUE) 
  n <- table(y)
  mk <- tapply(x,y,mean)
  sce <- sum(n*(mk-m)^2) 
  return(ifelse(sct>0,sce/sct,0))
}

## Relazione biunivoca tra v1 e v2. v1 ha più modalità.####
rel_biun3 = function(v1, v2 = dati$y, stampa = F, flag = F){
  tab = table(v1, v2)
  no_ok = 0 # conta il numero di osservazioni che rendono la relazione non biunivoca
  # flag = T # diventa F quando trova una riga con meno 0 del previsto
  m = length(unique(v2)) -1 # numero colonne tab-1
  num_zeri = rowSums(tab == 0) # conta il numero di 0 per ogni riga
  print(table(v1, v2))
  
  if(!stampa){
    for(el in num_zeri){
      if(el < m & !flag) return(flag) # se ci sono più righe con più valori diversi da 0 FINE
      if (el < m & flag) flag = F 
    }
    return(TRUE)
  }
  
  if(stampa) {
    for(i in 1:length(num_zeri)){
      if(num_zeri[i] < m) {
        if(no_ok != 0) flag = F
        no_ok = no_ok + min(tab[i,tab[i,] > 0])
      }
    }
    if(no_ok == 0) return(TRUE)
    print(paste(flag,'-> non biunivoca per', no_ok  , 'osservazioni'))
  }
}

leaker = function(data = dati, y = y, quantitative = F, variabili = qual, var_quant = quant){
  rel = c()
  if(quantitative == T) variabili = c(variabili, var_quant)
  for (el in variabili){
    rel =c(rel,rel_biun3(data[,el], data$y))
  }
  cbind(variabili, rel)[rel == TRUE,]
  return(variabili[which(rel == T)])
}

## Per passargli più variabili
#rel = c()
#for(col in names(dati)){
#  rel = c(rel, rel_biun(dati$Configuration, dati[,col]))
#}

#biun = data.frame(variabile = names(dati), biunivoca = rel)
#biun[biun$biunivoca == TRUE,]


## Aggregazione di modalità ####
# ritorna un vettore di dim = num.osservazioni con i nuovi gruppi.
aggregazione = function(df = dati, y = train$y, cat, heatplot = T, aggrega = F, id = id){
  id_cat = which(colnames(df) == cat)
  tipo = class(df[,id_cat]) # salvo che tipo di variabile è la categoriale
  df[,id_cat] = factor(df[,id_cat]) # trasformo la cat in fattore
  confronto = matrix(NA, length(levels(df[,id_cat])),
                     length(levels(df[,id_cat]))) 
  rownames(confronto) = colnames(confronto) = levels(df[,id_cat])
  diag(confronto) = 1
  for(i in 1:length(levels(df[,id_cat]))){
    # lm con categoria i-esima presa a riferimento
    m.cat = lm(y ~ relevel(df[id, id_cat], levels(df[,id_cat])[i]),
               data = df[id,])
    # pvalue confronto categorie con categoria presa a riferimento
    confronto[-i,i] = summary(m.cat)$coefficients[-1,4] 
  }
  
  ## heatplot
  # palette colori per scala pvalue
  if(heatplot){
    colori = c(
      rev(brewer.pal(5, "YlOrRd")), # significativo
      colorRampPalette(brewer.pal(5, "Blues"))(95)) # non significativo )
    idx = heatmap(ifelse(confronto > 0.05, 1, 0), verbose = F)$rowInd # riordina
    heatmap(confronto[idx, idx], Rowv = NA, Colv = NA, scale = "none", col = colori)
  }
  
  ## aggregazione
  if (aggrega){
    if(tipo == 'numeric') df[, id_cat] = as.numeric(df[, id_cat])
    else{ df[, id_cat] = as.character(df[, id_cat]) }
    
    
    fatto = c() # variabili già aggregate
    no_fatto = c() # variabile non ancora aggregate
    aggregate = rep(NA, dim(df)[1]) # nuove osservazioni
    n = 1 # numero gruppo
    fatto = c() # variabili aggregate
    
    for(el in colnames(confronto)){
      if (el %in% fatto) next
      if (length(colnames(confronto[,confronto[el, ] > .5] ) ) == 0) {
        aggregate[which(df[, id_cat] == el)] = el
        fatto = c(fatto, el)
      }
      
      else{
        lista = colnames(confronto[, confronto[el,] > .5]) # contiene le variabile con differenze non significative
        lista = lista[! lista %in% fatto]
        
        for(i in lista[-1]){
          print(i)
          if(! attr(which.max(confronto[confronto[,i] <1,i]), 'names') %in% lista) lista = lista[ -which( lista == i ) ]
          # se el non è la variabile "meno significativa" con i, allora si rimuove i dalla lista: l'idea è quella che verrà messa
          # ad un altro gruppo.
        }
        
        fatto = c(fatto, lista)
        
        if(is.numeric(df[, id_cat] )) {
          print('num')
          aggregate[which(df[, id_cat] %in% lista)] = n
          n = n+1
        }
        
        else{
          aggregate[which(df[, id_cat] %in% lista)] = paste0('gruppo',n)
          n = n+1
        }
        
        print(n)
      }
    }
    return(aggregate)
  }
  
}

## Convalida incrociata ####
cv_fun = function(dati = dati, variabile = '0', nfold = 4, fread = F, seme = 1, bilanc = 100){
  id_tot = c(1:dim(dati)[1]) # tutti gli id del dataset
  check = c() # inserisco le osservazioni già assegnate ad un fold in termini di id del datset
  cv_id = rep (NA, dim(dati)[1]) # inserisco le assegnazioni dei fold (inizializzo come un vettore n di NA)
  print(length(cv_id))
  if(variabile == '0'){ # cv normale
    set.seed(seme)
    cv_id = c(sample(rep(1:nfold, floor(dim(dati)[1]/nfold) ), rep = F))
    missing = rep(NA, dim(dati)[1] - length(cv_id))
    set.seed(seme)
    cv_id = sample(c(cv_id, missing))
    print(cv_id)
  }
  
  else{ # cv testerid
    id_var = which(colnames(dati) == variabile)
    if(!fread){
      set.seed (seme)
      for (i in 1:nfold){
        # dati non ancora usati
        usare = setdiff(id_tot, check)
        
        if(i == nfold) usati = unique(dati[usare,id_var])
        else{
          # salvo gli id delle osservazioni campionate per quel fold
          set.seed(seme)
          usati = sample(unique(dati[usare,id_var]),floor(length(unique(dati[,id_var]))/nfold))
        }
        
        print('ok')
        passo = which(dati[,id_var] %in% usati) # quali tester_id sono stati usati in questo passo
        
        # se cv_id = i ha troppe osservazioni, se ne levano alcune per renderlo più bilanciato
        while (length(passo) > floor(dim(dati)[1] / nfold) + bilanc){
          set.seed(seme+bilanc)
          usati = sample(usati, length(usati)-1)
          passo = which(dati[,id_var] %in% usati)
        }
        
        # se cv_id = i ha troppo poche osservazioni, se ne levano alcune per renderlo più bilanciato
        while (length(passo) < floor(dim(dati)[1] / nfold) - bilanc){
          set.seed(seme-bilanc)
          usati = c(usati, sample(unique(dati[usare,id_var]), 1))
          passo = which(dati[[id_var]] %in% usati)
          usare = setdiff(usare, passo)
        }

        check = c(check, passo) # aggiungo le osservazioni usate in questo passo a quelle usate in generale.
        cv_id[passo] = i
      }
      print(cv_id)
    }
    else{
      set.seed (seme)
      for (i in 1:nfold){
        print(i)
        # dati non ancora usati
        usare = setdiff(id_tot, check)
        
        # salvo gli id delle osservazioni campionate per quel fold
        if(i == nfold) usati = unique(dati[[id_var]][usare])
        else{
          set.seed(seme)
          usati = sample(unique(dati[[id_var]][usare]),floor(length(unique(dati[[id_var]]))/nfold))
          }
        print('ok')
        passo = which(dati[[id_var]] %in% usati) # quali tester_id sono stati usati in questo passo
        
        # se cv_id = i ha troppe osservazioni, se ne levano alcune per renderlo più bilanciato
        while (length(passo) > floor(dim(dati)[1] / nfold) + bilanc){
          set.seed(seme+bilanc)
          usati = sample(usati, length(usati)-1)
          passo = which(dati[[id_var]] %in% usati)
        }
        
        # se cv_id = i ha troppo poche osservazioni, se ne levano alcune per renderlo più bilanciato
        while (length(passo) < floor(dim(dati)[1] / nfold) - bilanc){
          set.seed(seme-bilanc)
          usati = c(usati, sample(unique(dati[[id_var]][usare]), 1))
          passo = which(dati[[id_var]] %in% usati)
          usare = setdiff(usare, passo)
        }
        print('check')
        check = c(check, passo) # aggiungo le osservazioni usate in questo passo a quelle usate in generale.
        cv_id[passo] = i
      }
    }
  }
  print(table(cv_id, useNA = 'always'))
  ## Assegno le osservazioni rimaste fuori (i.e. NA)
  if(length(which(is.na(cv_id))) > 0) cv_id[ which(is.na(cv_id))] = which.min(table(cv_id))
  
  #set.seed(seme)
  #new = sample(rep(1:nfold[-length(unique(cv_id))], length(which(is.na(cv_id))))) # nell'ultimo slot c'era NA.
  
  # n = 1
  #for (i in which(is.na(cv_id))){
  #if (i == n+1) cv_id[i] = cv_id[i-1]
  #else{ 
  #  set.seed(i)
  #  cv_id[i] = sample(new, 1)
  #}
  #n = i
  #}
  
  return(cv_id)
}

## Controllo che la convalida incrociata funzioni bene: tester id nello stesso cv ####
cv_ok = function(v1, v2 = cv_id[which(!is.na(cv_id))]){
  tt = table(as.character(v1[which(!is.na(v2))]), v2 )
  #print(tt)
  #print(length(which(tt == "0"))  )
  #print(length(unique(v1)) *( length(unique(v2) -1)))
  
  if(length(which(tt == "0"))  !=( length(unique(v1)) *( length(unique(v2)) -1))) return (FALSE)
  # il numero di 0 dovrebbe essere pari a nfold-1 per riga (ogni riga corrisponde ai valori unico della variabile)
  return(TRUE)
}

## Controllo che le categorie siano divide bene tra train e test ####
cat_train_test = function(dati = dati, id = id , test = 1, qual = qual, nfold = 3, num = 5, seme = 1, var = '0'){
  # id = id per train e test creato da cv_fun
  # test = id usato per assegnare al test set
  # qual = c(variabili qualitative)
  # num = numero massimo di livelli che posso stare nel train ma non nel test e viceversa
  # seme = seme usato da cv_fun
  
  nffold = nfold
  nn = num
  idd = id
  ss = seme
  testt = test
  varr = var
  
  ## Verifico se ci sono dei livelli delle variabili cat nel test e non nel train
  n = 0
  for (qualitativa in qual){
    for (el in unique(dati[id == test ,qualitativa])){
      if (!el %in% unique(dati[id != test,qualitativa])){ 
        print(paste('valore in test:' ,qualitativa, el))
        n = n+1
      }
    }
  }
  print(n)
  
  m = 0
  for (qualitativa in qual){
    for (el in unique(dati[id != test,qualitativa])){
      if (!el %in% unique(dati[id == test,qualitativa])){
        print(paste('valore in train:' ,qualitativa, el))
        print(el)
        m = m+1
      }
    }
  }
  print(m)
  
  if (m > num | n > num) {
    print(paste('seme:', ss))
    ss = ss+1
    idd = cv_fun(dati = dati, nfold = nffold, seme = ss, variabile = varr)
    idd = cat_train_test(dati = dati, id = idd, test = testt, qual = qual, nfold = nffold, num = nn, seme = ss, var = varr )
  }
  return(idd)
}

##QUESTA
train_test2 = function(dati = dati, id = id , qual = qual, num = 0, seme = 1, var = '0', bilanc = 100, valutazione = F, print = T){
  # id = id per train e test creato da cv_fun
  # qual = c(variabili qualitative)
  # num = numero massimo di livelli che posso stare nel train ma non nel test e viceversa
  # seme = seme usato da cv_fun
  
  nfold = length(unique(id))
  nn = num
  idd = id
  ss = seme
  varr = var
  bb = bilanc
  n =1
  m = 1
  
  ## Verifico se ci sono dei livelli delle variabili cat nel test e non nel train
  iter = 1   # iter = id usato per assegnare al test set
  while((iter < (nfold+1)) & ( m > num | n > num)){ # fino max numero iterazioni (proviamo ad assegnare test ad ogni possibile fold) o finché non ci sono problemi 
    print(paste('iter:', iter))
    
    # qualitative in test, ma non in train
    n = 0
    for (qualitativa in qual){
      for (el in unique(dati[id == iter ,qualitativa])){
        if (!el %in% unique(dati[id != iter,qualitativa])){ 
          if(valutazione & print)print(paste('valore in test:' ,qualitativa, el))
          n = n+1
        }
      }
    }
    print(paste('n=',n))
    
    # quantitative in train, ma non in test
    m = 0
    for (qualitativa in qual){
      for (el in unique(dati[id != iter,qualitativa])){
        if (!el %in% unique(dati[id == iter,qualitativa])){
          if(valutazione & print) print(paste('valore in train:' ,qualitativa, el))
          #print(el)
          m = m+1
        }
      }
    }
    print(paste('m=',m))
    iter = iter +1 
  }
  
  if(valutazione & m == num & n == num) return(iter-1)
  if(valutazione &( m!= num | n != num)) return('no okay')
  
  if (m > num | n > num) { # se per nessun fold si ha quello che si vuole
    ss = ss+1 # cambio seme
    print(paste('seme:', ss))
    idd = cv_fun(dati = dati, nfold = nfold, seme = ss, variabile = varr, bilanc = bb) # ricampiono con cv_fun cambiando il seme
    idd = train_test2(dati = dati, id = idd, qual = qual, 
                      num = nn, seme = ss, var = varr, bilanc = bb ) # applico di nuovo la funzione sul nuovo cv
  }
  return(idd)
}

train_test3 = function(dati = dati, id = id , qual = qual, num = 0, seme = 1, var = '0', 
                       bilanc = 100, valutazione = F, print = T,  y = 'y',
                       solo_controllo = F){
  # id = id per train e test creato da cv_fun
  # qual = c(variabili qualitative)
  # num = numero massimo di livelli che posso stare nel train ma non nel test e viceversa
  # seme = seme usato da cv_fun
  # controllo = se T => sottocampionamento del train (controllare prima classi sbilanciate)
  #solo_controllo = se T => fa solo un'iterazione di controllo
  
  nfold = length(unique(id))
  nn = num
  idd = id
  ss = seme
  varr = var
  bb = bilanc
  n =1
  m = 1
  if(solo_controllo) valutazione = T
  
  ## Verifico se ci sono dei livelli delle variabili cat nel test e non nel train
  iter = 1   # iter = id usato per assegnare al test set
  while((iter < (nfold+1)) & ( m > num | n > num)){ # fino max numero iterazioni (proviamo ad assegnare test ad ogni possibile fold) o finché non ci sono problemi 
    print(paste('iter:', iter))
    
    # qualitative in test, ma non in train
    n = 0
    for (qualitativa in qual){
      for (el in unique(dati[id == iter ,qualitativa])){
        if (!el %in% unique(dati[id != iter,qualitativa])){ 
          if(valutazione & print)print(paste('valore in test:' ,qualitativa, el))
          n = n+1
        }
      }
    }
    print(paste('n=',n))
    
    # quantitative in train, ma non in test
    m = 0
    for (qualitativa in qual){
      for (el in unique(dati[id != iter,qualitativa])){
        if (!el %in% unique(dati[id == iter,qualitativa])){
          if(valutazione & print) print(paste('valore in train:' ,qualitativa, el))
          #print(el)
          m = m+1
        }
      }
    }
    print(paste('m=',m))
    iter = iter +1 
    if(solo_controllo) iter = nfold + 2
  }
  
  if(valutazione & m == num & n == num) return(iter-1)
  if(valutazione &( m!= num | n != num)) return('no okay')
  
  if (m > num | n > num) { # se per nessun fold si ha quello che si vuole
    ss = ss+1 # cambio seme
    print(paste('seme:', ss))
    idd = cv_fun(dati = dati, nfold = nfold, seme = ss, variabile = varr, bilanc = bb) # ricampiono con cv_fun cambiando il seme
    idd = train_test2(dati = dati, id = idd, qual = qual, 
                      num = nn, seme = ss, var = varr, bilanc = bb ) # applico di nuovo la funzione sul nuovo cv
  }
  
  id2 = ifelse(idd == (iter-1), 1, 2) # 1 -> test ; 2 -> train
  return(id2)
}

## Controllo che le categorie siano divide bene tra cv_id ####
cv_controllo = function(dati = dati, id = id , qual = qual, num = 0, seme = 1, var = '0', 
                        bilanc = 100, print = T, sottocamp = 0, y = 'y'){
  # id = id per train e test creato da cv_fun
  # qual = c(variabili qualitative)
  # num = numero massimo di livelli che posso stare nel train ma non nel test e viceversa
  # seme = seme usato da cv_fun
  # controllo = se T => sottocampionamento del train (controllare prima classi sbilanciate)
  
  nfold = length(unique(id))
  nn = num
  idd = id
  ss = seme
  varr = var
  bb = bilanc
  n =0
  m = 0
  
  
  ## Verifico se ci sono dei livelli delle variabili cat nel test e non nel train
  iter = 1   # iter = id usato per assegnare al test set
  while((iter < (nfold+1)) & ( m <= num & n<=num)){ # fino max numero iterazioni (proviamo ad assegnare test ad ogni possibile fold) o finché non ci sono problemi 
    print(paste('iter:', iter))
    
    # qualitative in test, ma non in train
    n = 0
    for (qualitativa in qual){
      for (el in unique(dati[id == iter ,qualitativa])){
        if (!el %in% unique(dati[id != iter,qualitativa])){ 
          if( print) print(paste('valore in fold', iter, ':' ,qualitativa, el))
          n = n+1
        }
      }
    }
    print(paste('n=',n))
    
    # quantitative in train, ma non in test
    m = 0
    for (qualitativa in qual){
      for (el in unique(dati[id != iter,qualitativa])){
        if (!el %in% unique(dati[id == iter,qualitativa])){
          if(print) print(paste('valore fuori fold', iter, ':' ,qualitativa, el))
          #print(el)
          m = m+1
        }
      }
    }
    print(paste('m=',m))
    iter = iter +1 
  }
  
  
  if (m > num | n > num) { # se per nessun fold si ha quello che si vuole
    ss = ss+1 # cambio seme
    print(paste('seme:', ss))
    idd = cv_fun(dati = dati, nfold = nfold, seme = ss, variabile = varr, bilanc = bb) # ricampiono con cv_fun cambiando il seme
    idd = cv_controllo(dati = dati, id = idd, qual = qual, 
                       num = nn, seme = ss, var = varr, bilanc = bb ) # applico di nuovo la funzione sul nuovo cv
  }
  
  return(idd)
}



##### FUNZIONI PER LA VALUTAZIONE DELLA PREVISIONE ##### 

get_err <- function(pred, obs = dati[-id,'y']){ 
  mse <- mean((pred-obs)^2)
  mae <- mean(abs(pred - obs))
  return(t(data.frame(mse = mse, mae = mae)))
}
wmse = function ( pred, obs = test$y, pesi = rep(1, length(pred))){ mean(pesi*(pred-obs)^2) }
mae = function( pred, obs = test$y ){mean(abs(pred - obs))}

matrice_errori_prev = function(nome, pred, matrice =  data.frame( Modello = c(0), MSE = c(0), MAE = c(0)), 
                               w = rep(1, length(pred)), 
                               obs = test$y){
  i = 1
  #print(matrice)
  if (matrice[1,1] != 0){ i = dim(matrice)[1]+1 }
  if(names(table(w == rep(1, length(pred))))[1] == 'FALSE'){  
    if(matrice[1,1] == 0){ matrice = rename(matrice, WMSE = MSE)}
    matrice[,3] = NULL
    matrice[i,] = c(nome, round(wmse(pred, pesi = w), 4)) 
  }
  else{ matrice[i,] = c(nome, round(wmse( pred, pesi = w), 4), round(mae(pred), 4)) }
  #print(matrice |>knitr::kable())
  return(matrice)
}



##### FUNZIONI PER LA VALUTAZIONE DELLA CLASSIFICAZIONE ##### 
##### curve lift e roc
lift.roc<- function(previsti, g, type="bin", plot.it=TRUE) # g = numerico test set
{
  library(sm)
  if(!is.numeric(g)) stop("g not numeric")
  ind <- rev(order(previsti))
  n <- length(g)
  x1 <-  (1:n)/n
  x2 <- cumsum(g[ind])/(mean(g)*(1:n))
  if(type=="crude" & plot.it) 
    plot(x1, x2, type="l", col=2,
         xlab="frazione di soggetti previsti", ylab="lift")
  if(type=="sm") {
    a<- sm.regression(x1, x2, h=0.1, display="none")
    if(plot.it)
      plot(a$eval, a$estimate, type="l",xlim=c(0,1), col=2,
           xlab="frazione di soggetti previsti", ylab="lift")
  }
  if(type=="bin") {
    b <-  binning(x1,x2, breaks=(-0.001:10)/9.999)
    x <- c(0,seq(0.05,0.95, by=0.1),1)
    if(plot.it) plot(x, c(x2[1],b$means,1), type="b", xlim=c(0,1),
                     ylim=c(1,max(x2)), cex=0.75, col=2,
                     xlab="frazione di soggetti previsti",
                     ylab="fattore di miglioramento")
    x1<- x
    x2<- c(x2[1],b$means,1)
  }
  if(plot.it) {cat("premere <cr>"); readline()}
  u1<- cumsum(1-g[ind])/sum(1-g)
  u2<- cumsum(g[ind])/sum(g)
  if(type=="crude" & plot.it)
    plot(u1, u2, type="l", xlim=c(0,1), ylim=c(0,1), col=2,
         xlab="1-specificita`", ylab="sensibilita`")
  if(type=="sm") {
    # browser()
    eps<- 0.00001
    a<- sm.regression(u1,log((u2+eps)/(1-u2+2*eps)), h=0.1, display="none")
    q<- exp(a$estimate)/(1+exp(a$estimate))
    if(plot.it) plot(a$eval, q, type="l", xlim=c(0,1), ylim=c(0,1),
                     xlab="1-specificita`", ylab="sensibilita`", col=2)
  }
  if(type=="bin") {
    b <- binning(u1,u2, breaks=(-0.001:10)/9.999)
    x <- c(0,seq(0.05,0.95, by=0.1),1)
    y<- c(0,b$means,1)
    if(plot.it)
      plot(x, y, type="b", xlim=c(0,1),
           ylim=c(0,1),cex=0.75, xlab="1-specificita`",
           ylab="sensibilita`", col=2)
    u1<- x
    u2<- y
  }                      
  if(plot.it) {
    abline(0,1, lty=2, col=3)
  }
  invisible(list(x1,x2,u1,u2))
}

# funzione che calcola matrice di confusione e gli errori di classificazione
tabella.sommario <- function(previsti, osservati, livelli = c(F,T)){
  previsti=  factor(previsti,levels = livelli)
  osservati = factor(osservati)
  n <-  table(previsti,osservati)
  err.tot <- 1-sum(diag(n))/sum(n)
  fn <- n[1,2]/(n[1,2]+n[2,2])
  fp <- n[2,1]/(n[1,1]+n[2,1])
  print(n)
  cat("errore totale: ", format(err.tot),"\n")
  cat("falsi positivi & falsi negativi: ",format(c(fp, fn)),"\n")
  invisible(n)
}

##### Errori #####
accur = function(previsti, osservati, livelli = c(F,T)){
  previsti=  factor(previsti,levels = livelli)
  osservati = factor(osservati)
  tab <-  table(previsti,osservati)
  # tutti quelli previsti bene / tutti
  return(round((tab[1] + tab[4])/sum(tab), 4))
}

precision = function(previsti, osservati, livelli = c(F,T), tab = c(0)){
  if(length(tab) == 1){
    previsti=  factor(previsti,levels = livelli)
    osservati = factor(osservati)
    tab <-  table(previsti,osservati)
  }
  return( round(tab[4]/(tab[2] + tab[4]), 4)) # tutti i veri positivi / tutti i previsti positivi
}

recall = function(previsti, osservati, livelli = c(F,T), tab = c(0)){
  if(length(tab) == 1){
    previsti=  factor(previsti,levels = livelli)
    osservati = factor(osservati)
    tab <-  table(previsti,osservati)
  }
  return(rec = round(tab[4]/(tab[3] + tab[4]), 4)) #tutti i veri positivi / tutti i positivi osservati
  
}


F1 = function(previsti, osservati, livelli = c(F,T)){
  previsti=  factor(previsti,levels = livelli)
  osservati = factor(osservati)
  tab <-  table(previsti,osservati)
  
  prec = precision(previsti, osservati, livelli = c(F,T), tab)
  rec = recall (previsti, osservati, livelli = c(F,T), tab)
  
  return(round(2 /(1/prec + 1/rec), 4 ))#2/(1/recupero + 1/precisione)
}


# falsi positivi, falsi negativi,...
errori = function (previsti, osservati){
  n <-  table(previsti,osservati)
  err.tot <- 1-sum(diag(n))/sum(n)
  fn <- n[1,2]/(n[1,2]+n[2,2])
  fp <- n[2,1]/(n[1,1]+n[2,1])
  return (c ('tot' = err.tot, 'fn' = fn, 'fp' = fp))
}

# funzione per calcolare i tassi per i diversi valori di parametro di regolazione per glmnet
ce = function(osservati, previsti) {
  tt = table(osservati, previsti)
  err = 1 - sum(diag(tt))/sum(tt)
}


## Matrice degli errori finale
matrice_errori_clf1 = function ( nome, tab,
                                 matr.err = data.frame(Modello = c(0),Accuratezza=c(0), Precisione = c(0), Recupero = c(0), F1 = c(0)) ){
  #tab = matrix(tabella, ncol= 4)
  i = 1
  if (matr.err[1,1] != 0){ i = dim(matr.err)[1]+1  }
  acc = round((tab[1] + tab[4])/sum(tab), 3)   # tutti quelli previsti bene / tutti
  prec = round(tab[4]/(tab[2] + tab[4]), 3) # tutti i veri positivi / tutti i previsti positivi
  rec = round(tab[4]/(tab[3] + tab[4]), 3) #tutti i veri positivi / tutti i positivi osservati
  f1 = round(2 /(1/prec + 1/rec), 3 )# 2/(1/recupero + 1/precisione)
  matr.err [i, ] = c(nome, acc, prec, rec, f1)
  print(matr.err |>knitr::kable())
  return(matr.err )
}

matrice_errori_clf_cv = function( nome, errs,
                                  matr.err = data.frame(Modello = c(0),Accuratezza=c(0), 
                                                        Precisione = c(0), Recupero = c(0), 
                                                        F1 = c(0))
                                  , accuratezza = T){
  i = 1
  if (matr.err[1,1] != 0){ i = dim(matr.err)[1]+1  }
  if(accuratezza) matr.err[i,] = c(nome, round(errs, 3))
  else{matr.err[i,] = c(nome, round(1-errs[1], 3), round(errs[2:4], 3))}
  print(matr.err |>knitr::kable())
  return(matr.err )
}


###      acc = (tab[i] + tab[i,4])/sum(tab[i,])   # tutti quelli previsti bene / tutti
###      prec = tab[i,4]/(tab[i,2] + tab[i,4]) # tutti i veri positivi / tutti i previsti positivi
###      rec = tab[i,4]/(tab[i,3] + tab[i,4]) #tutti i veri positivi / tutti i positivi osservati
###      f1 = 2 /(1/prec + 1/rec) # 1/(1/recupero + 1/precisione)
###      mat.err [i, ] = round(c(acc, prec, rec, f1), 3)


# tabella di confusione forzata ad essere 2x2
fun.errori <- function(previsti, osservati){
  # forziamo la tabella ad essere una 2x2
  pr_f =  factor(previsti,levels = c(F, T))
  true_f = factor(osservati)
  
  tabella = table(pr_f, true_f)
  
  c("ce" = 1-sum(diag(tabella))/sum(tabella), 
    "fp" = tabella[2,1]/(tabella[1,1]+tabella[2,1]),  # alpha
    "fn" = tabella[1,2]/(tabella[1,2]+tabella[2,2]),  # beta
    "F1" = 2*tabella[2,2]/(2*tabella[2,2]+tabella[2,1]+tabella[1,2]))
}

fun.errori2 <- function(previsti, osservati){
  # forziamo la tabella ad essere una 2x2
  pr_f =  factor(previsti,levels = c(F, T))
  true_f = factor(osservati)
  
  tabella = table(pr_f, true_f)
  
  c("accuratezza" = sum(diag(tabella))/sum(tabella), 
    "precisione" = tabella[2,2]/(tabella[2,1]+tabella[2,2]),  
    "recupero" = tabella[2,2]/(tabella[1,2]+tabella[2,2]),  
    "F1" = 2*tabella[2,2]/(2*tabella[2,2]+tabella[2,1]+tabella[1,2]))
}
