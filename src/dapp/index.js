
import DOM from './dom';
import Contract from './contract';
import './flightsurety.css';


(async() => {

    let result = null;

    let contract = new Contract('localhost', () => {

        // Read transaction
        contract.isOperational((error, result) => {
            console.log(error,result);
            display('Operational Status', 'Check if contract is operational', [ { label: 'Operational Status', error: error, value: result} ]);
        });
        // fetch list of registered flights from server and add them to selection forms
        function fetchAndAppendFlights () {
            fetch('http://localhost:3000/flights')
              .then(res => {
                return res.json()
              })
              .then(flights => {
                flights.forEach(flight => {
                  // append only flights that haven't been processed yet
                  if (flight.flight.statusCode == 0) {
                    let {
                      index,
                      flight: { price, flightRef, from, to, takeOff, landing }
                    } = flight
                    price = price / 1000000000000000000
                    // append flight to passenger selection list
                    let datalist = DOM.elid('flights')
                    let option = DOM.option({ value: `${index} - ${price} ETH - ${flightRef} - ${from} - ${parseDate(+takeOff)} - ${to} - ${parseDate(+landing)}` })
                    datalist.appendChild(option)
                    // append to oracle submission list
                    datalist = DOM.elid('oracle-requests')
                    option = DOM.option({ value: `${flightRef} - ${to} - ${parseDate(+landing)}` })
                    datalist.appendChild(option)
                  }
                })
              })
          }
          fetchAndAppendFlights()

        // User-submitted transaction
        DOM.elid('submit-oracle').addEventListener('click', () => {
            let flight = DOM.elid('flight-number').value;
            // Write transaction
            contract.fetchFlightStatus(flight, (error, result) => {
                display('Oracles', 'Trigger oracles', [ { label: 'Fetch Flight Status', error: error, value: result.flight + ' ' + result.timestamp} ]);
            });
        })

            // (airline) Register airline
    DOM.elid('register-airline').addEventListener('click', async () => {
        const newAirline = DOM.elid('regAirlineAddress').value
        await contract.registerAirline(newAirline)
        const { address, votes, error } = await contract.registerAirline(newAirline)
        display(
          `Airline ${sliceAddress(address)}`,
          'Register Airline', [{
            label: sliceAddress(newAirline),
            error: error,
            value: `${votes} more vote(s) required`
          }]
        )
      })
    
    });
    
    // (airline) Register flight
    DOM.elid('register-flight').addEventListener('click', async () => {
        const takeOff = new Date(DOM.elid('regFlightTakeOff').value).getTime()
        const landing = new Date(DOM.elid('regFlightLanding').value).getTime()
        const flightRef = DOM.elid('regFlightRef').value
        const price = DOM.elid('regFlightPrice').value
        const from = DOM.elid('regFlightFrom').value
        const to = DOM.elid('regFlightTo').value
        await contract.registerFlight(
          takeOff,
          landing,
          flightRef,
          price,
          from,
          to)
      })
  
      // Provide funding
      DOM.elid('fund').addEventListener('click', () => {
        let amount = DOM.elid('fundAmount').value
        contract.fund(amount, (error, result) => {
          display(`Airline ${sliceAddress(result.address)}`, 'Provide Funding', [{
            label: 'Funding',
            error: error,
            value: `${result.amount} ETH` }])
        })
      })
  
      // Book flight
      DOM.elid('buy').addEventListener('click', async () => {
        // destructure and get index
        let input = DOM.elid('buyFlight').value
        input = input.split('-')
        input = input.map(el => { return el.trim() })
        const index = input[0]
        const insurance = DOM.elid('buyAmount').value
        // Fetch args from server
        fetch('http://localhost:3000/flights')
          .then(res => { return res.json() })
          .then(flights => {
            return flights.filter(el => { return el.index == index })
          })
          .then(async flight => {
            // These are all STRINGS
            const { flight: { flightRef, to, landing, price } } = flight[0]
            // execute transaction
            const { passenger, error } = await contract.book(
              flightRef,
              to,
              landing,
              price / 1000000000000000000,
              insurance)
            display(
              `Passenger ${sliceAddress(passenger)}`,
              'Book flight',
              [{
                label: `${flightRef} to ${to} lands at ${landing}`,
                error: error,
                value: `insurance: ${insurance} ETH`
              }]
            )
          })
 
  
      // Withdraw funds
      DOM.elid('pay').addEventListener('click', () => {
        try {
          contract.withdraw()
        } catch (error) {
          console.log(error.message)
        }
      })
    })
 
})();

function populateSelect(type, selectOpts, el){
  let select = DOM.elid(type + el);
  
  let index = type == 'airline' ? 0: 1;
  
  selectOpts.forEach(opt => {
      
      if((type  == 'airline' && opt[2] == false) || type == 'flights'){
              select.appendChild(DOM.option({value: opt[index]}, opt[1] ));
      }
  });
  
}

function displayOperStatus(title, description, results) {
  let displayDiv = DOM.elid("display-operational-status");
  let section = DOM.section();
  section.appendChild(DOM.h4(title));
  section.appendChild(DOM.h5(description));
  results.map((result) => {
      let row = section.appendChild(DOM.div({className:'row'}));
      row.appendChild(DOM.div({className: 'col-sm-4 field'}, result.label));
      row.appendChild(DOM.div({className: 'col-sm-8 field-value'}, result.error ? String(result.error) : String(result.value)));
      section.appendChild(row);
  })
  displayDiv.append(section);
}

function displayContractBal(description, balance) {
  let displayDiv = DOM.elid("display-contract-balance");
  displayDiv.innerHTML = "";
  let section = DOM.section();
  section.appendChild(DOM.h5(description));
  section.appendChild(DOM.div({className: 'col-sm-8 field-value'}, balance));
  displayDiv.append(section);
}


function flightChange(el, n, flights){
  el = el + n
  let flight = DOM.elid(el).value;
  let flightArr = [];
  
  for (var i = 0; i < flights.length; i++){
      if(flights[i][1] == flight){
          flightArr.push(flights[i]);
          break;
      }
  }
  
  let num = el.charAt(el.length - 1);
  if( n > 1)
  displayFlightInfo(num, flightArr);
}

function displayFlightInfo(num, flight) {
  let divname = "flightInfo" + num;
  let displayDiv = DOM.elid(divname);
  displayDiv.innerHTML = "";
  let section = DOM.section();
  
  let line1 = "Airlines: " + flight[0][6] + " Departs at: " + flight[0][3];
  let line2 = "Departs From: " + flight[0][4] + " Lands at: " + flight[0][5];
  
  section.appendChild(DOM.div({className: 'col-sm-4 field', style: { margin: 'auto 0 auto 0'}}, line1));
  section.appendChild(DOM.div({className: 'col-sm-4 field', style: { margin: 'auto 0 auto 0'}}, line2));
  displayDiv.append(section);
}

function displayFund(title, results) {
  let displayDiv = DOM.elid("display-wrapper-funding-status");
  let section = DOM.section();
  section.appendChild(DOM.h5(title));
  results.map((result) => {
      let row = section.appendChild(DOM.div({className:'row'}));
      row.appendChild(DOM.div({className: 'col-sm-4 field'}, String(result.airline) + " Funded."));
      row.appendChild(DOM.div({className: 'col-sm-8 field-value'}, result.TXid ? ("TX Id : " + String(result.TXid)) : ("Funded : TX: " + String(result.airline))));
      section.appendChild(row);
  })
  displayDiv.append(section);
}

function displayFlightStatus(divID, title, description, status, results) {
  //console.log(results)
  let displayDiv = DOM.elid(divID);
  displayDiv.innerHTML = "";
  let section = DOM.section();
  
  section.appendChild(DOM.h5(description));
  
      let row = section.appendChild(DOM.div({className:'row'}));
      row.appendChild(DOM.div({className: 'col-sm-4 field'}, results[0].label));
      let displayStr = String(results[0].value);
     
      switch(status){
          case "0" :
              displayStr = displayStr + " : Unknown";
              break;
          case "10" :
              displayStr = displayStr + " : On Time";
              break;
          case "20" :
              displayStr = displayStr + " : Late due to Airline";
              break;
          case "30" :
              displayStr = displayStr + " : Late due to weather";
              break;
          case "40" :
              displayStr = displayStr + " : Late due to technical problems";
              break;
          case "50" :
              displayStr = displayStr + " : Late due to other reasons";
              break;
          }
      
      row.appendChild(DOM.div({className: 'col-sm-8 field-value'}, results[0].error ? String(results[0].error) : displayStr));
      section.appendChild(row);
  
  displayDiv.append(section);

}

function displayInsurance(title, results) {
  let displayDiv = DOM.elid("display-wrapper-insurance-status");
  let section = DOM.section();
  section.appendChild(DOM.h5(title));
  results.map((result) => {
      let row = section.appendChild(DOM.div({className:'row'}));
      row.appendChild(DOM.div({className: 'col-sm-4 field'}, result.label));
      //row.appendChild(DOM.div({className: 'col-sm-8 field-value'}, result.error ? String(result.error) : String(result.flight)));
      //console.log(result.text);
      row.appendChild(DOM.div({className: 'col-sm-8 field-value'}, String(result.text)));
      section.appendChild(row);
  })
  displayDiv.append(section);

}

function fillInsuranceInfo(title, flight){
  let displayDiv = DOM.elid("display-wrapper-insurance-info");
  if(displayDiv.innerHTML.length == 0){
      displayDiv.appendChild(DOM.label(title));
  }
  displayDiv.appendChild(DOM.label(" - " + flight + " "));
}




