let
    Origine = (ticker) => let
        //* symbol = tiker,
        symbol = ticker,
        interval = "1d",
        // Con il metodo meta basta un range minimo di 1 giorno per avere l'ultimo prezzo assoluto
        daterange = "1d", 
        Source = Json.Document(Web.Contents("https://query1.finance.yahoo.com/v8/finance/chart/" & symbol & "?region=US&lang=en-US&includePrePost=false&interval=" & interval & "&range=" & daterange)),
        
        // Navigazione diretta nel record dei metadati
        result = Source[chart][result]{0},
        Meta = result[meta],
        
        TickerSymbol = Meta[symbol],
        
        // Estrazione dell'ultimo prezzo e del timestamp esatto dell'ultimo scambio
        UltimoPrezzo = Meta[regularMarketPrice],
        UnixTimestamp = Meta[regularMarketTime],
        
        // Creazione del record singolo (evita di creare liste e zipparle)
        RecordFinale = [
            Symbol = TickerSymbol,
            UnixTimestamp = UnixTimestamp,
            AdjustedClose = UltimoPrezzo
        ],
        
        // Conversione del record in Tabella
        FinalTable = Table.FromRecords({RecordFinale}),
    
        // Convertiamo il timestamp in data leggibile UTC
        #"Added Date" = Table.AddColumn(FinalTable, "Date UTC", each #datetime(1970, 1, 1, 0, 0, 0) + #duration(0, 0, 0, [UnixTimestamp]), type datetime),
        
        // Convertiamo la colonna Date da UTC all'ora locale del sistema italiano
        #"Convertito in Ora Locale" = Table.AddColumn(#"Added Date" , "Date", each DateTimeZone.RemoveZone(DateTimeZone.ToLocal(DateTime.AddZone([Date UTC], 0))), type datetime),
        
        // Tipizzazione dei dati finali
        #"Modificato tipo" = Table.TransformColumnTypes(#"Convertito in Ora Locale",{{"AdjustedClose", type number}, {"Symbol", type text}}),
        
        // Pulizia e riordinamento colonne (mantenendo la stessa identica struttura del tuo output precedente)
        #"Removed Timestamps" = Table.RemoveColumns(#"Modificato tipo",{"UnixTimestamp","Date UTC"}),
        #"Reordered Columns" = Table.ReorderColumns(#"Removed Timestamps",{"Symbol", "Date", "AdjustedClose"})
    in
        #"Reordered Columns"
in
    Origine
