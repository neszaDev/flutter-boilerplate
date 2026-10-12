import 'package:flutter_boilerplate/features/showcase/forms/combobox.dart';

/// Card expiry months, as on the web's credit card form.
const cardMonths = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

/// Card expiry years: twelve years from 2026.
const cardYears = [2026, 2027, 2028, 2029, 2030, 2031, 2032, 2033, 2034, 2035, 2036, 2037];

/// Numbers of the sample options (`Option 1` … `Option 3`).
const optionNumbers = [1, 2, 3];

/// Column spans of the input grid example (out of 12).
const gridSpans = [3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

/// Right-hand spans of the two split-grid examples; the left side takes the rest of 12.
const splitSpans = [4, 5, 6, 7, 8];

/// US states and territories, the option list of the multiselect demos (American Samoa is
/// disabled). Proper names, so not translated.
const usStates = [
  ComboboxOption(value: 'AL', label: 'Alabama'),
  ComboboxOption(value: 'AK', label: 'Alaska'),
  ComboboxOption(value: 'AS', label: 'American Samoa', disabled: true),
  ComboboxOption(value: 'AZ', label: 'Arizona'),
  ComboboxOption(value: 'AR', label: 'Arkansas'),
  ComboboxOption(value: 'CA', label: 'California'),
  ComboboxOption(value: 'CO', label: 'Colorado'),
  ComboboxOption(value: 'CT', label: 'Connecticut'),
  ComboboxOption(value: 'DE', label: 'Delaware'),
  ComboboxOption(value: 'DC', label: 'District Of Columbia'),
  ComboboxOption(value: 'FM', label: 'Federated States Of Micronesia'),
  ComboboxOption(value: 'FL', label: 'Florida'),
  ComboboxOption(value: 'GA', label: 'Georgia'),
  ComboboxOption(value: 'GU', label: 'Guam'),
  ComboboxOption(value: 'HI', label: 'Hawaii'),
  ComboboxOption(value: 'ID', label: 'Idaho'),
  ComboboxOption(value: 'IL', label: 'Illinois'),
  ComboboxOption(value: 'IN', label: 'Indiana'),
  ComboboxOption(value: 'IA', label: 'Iowa'),
  ComboboxOption(value: 'KS', label: 'Kansas'),
  ComboboxOption(value: 'KY', label: 'Kentucky'),
  ComboboxOption(value: 'LA', label: 'Louisiana'),
  ComboboxOption(value: 'ME', label: 'Maine'),
  ComboboxOption(value: 'MH', label: 'Marshall Islands'),
  ComboboxOption(value: 'MD', label: 'Maryland'),
  ComboboxOption(value: 'MA', label: 'Massachusetts'),
  ComboboxOption(value: 'MI', label: 'Michigan'),
  ComboboxOption(value: 'MN', label: 'Minnesota'),
  ComboboxOption(value: 'MS', label: 'Mississippi'),
  ComboboxOption(value: 'MO', label: 'Missouri'),
  ComboboxOption(value: 'MT', label: 'Montana'),
  ComboboxOption(value: 'NE', label: 'Nebraska'),
  ComboboxOption(value: 'NV', label: 'Nevada'),
  ComboboxOption(value: 'NH', label: 'New Hampshire'),
  ComboboxOption(value: 'NJ', label: 'New Jersey'),
  ComboboxOption(value: 'NM', label: 'New Mexico'),
  ComboboxOption(value: 'NY', label: 'New York'),
  ComboboxOption(value: 'NC', label: 'North Carolina'),
  ComboboxOption(value: 'ND', label: 'North Dakota'),
  ComboboxOption(value: 'MP', label: 'Northern Mariana Islands'),
  ComboboxOption(value: 'OH', label: 'Ohio'),
  ComboboxOption(value: 'OK', label: 'Oklahoma'),
  ComboboxOption(value: 'OR', label: 'Oregon'),
  ComboboxOption(value: 'PW', label: 'Palau'),
  ComboboxOption(value: 'PA', label: 'Pennsylvania'),
  ComboboxOption(value: 'PR', label: 'Puerto Rico'),
  ComboboxOption(value: 'RI', label: 'Rhode Island'),
  ComboboxOption(value: 'SC', label: 'South Carolina'),
  ComboboxOption(value: 'SD', label: 'South Dakota'),
  ComboboxOption(value: 'TN', label: 'Tennessee'),
  ComboboxOption(value: 'TX', label: 'Texas'),
  ComboboxOption(value: 'UT', label: 'Utah'),
  ComboboxOption(value: 'VT', label: 'Vermont'),
  ComboboxOption(value: 'VI', label: 'Virgin Islands'),
  ComboboxOption(value: 'VA', label: 'Virginia'),
  ComboboxOption(value: 'WA', label: 'Washington'),
  ComboboxOption(value: 'WV', label: 'West Virginia'),
  ComboboxOption(value: 'WI', label: 'Wisconsin'),
  ComboboxOption(value: 'WY', label: 'Wyoming'),
];
