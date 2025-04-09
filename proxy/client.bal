import ballerina/http;

listener http:Listener httpListener = new (8080);

public type Country record {
    string Country;
    string Continent;
    int Population;
    float Area;
};


service / on httpListener {
    resource function get countries() returns json|error { 
    // Creating an HTTP client to connect to the server.
    http:Client countriesClient = check new ("https://25406727-19f8-46ba-b332-4f3167a29de0-dev.e1-us-east-azure.choreoapis.dev/default/sample-backend/v1.0");

    // Sending a GET request to the "/countries" endpoint and retrieving an array of `Country` records.
    Country[] countries = check countriesClient->/countries;

    // Using a query expression to process the list of countries and generate a summary.
    json summary =
        from var {Country, Continent, Population, Area} in countries
            where Population >= 100000000 && Area >= 1000000.0       // Filtering countries with a population >= 100M and area >= 1M sq km.
            let decimal populationDensity = <decimal>Population / <decimal>Area // Calculating population density.
            order by populationDensity descending                    // Sorting the results by population density in descending order.
            limit 10                                                 // Limiting the results to the top 10 countries.
            select {Country, Continent, populationDensity};          // Selecting the country name, continent, and population density.

    // Printing the summary as JSON to the console.
    return summary;
    }
}