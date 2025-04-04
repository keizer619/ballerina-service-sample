import ballerina/http;
import ballerina/io;
import ballerina/data.csv;

public type Country record {
    string Country;
    string Capital;
    string Continent;
    int Population;
    float Area;
    string Languages;
    string Currency;
};

service / on new http:Listener(9090) {
     resource function get countries() returns Country[] | error {
            // Read the CSV content as a string
            string csvContent = check io:fileReadString("countries.csv");
            Country[] countries = check csv:parseString(csvContent);
            return countries;
    }
}
