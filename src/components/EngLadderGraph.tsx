import React, { useState, type ChangeEventHandler, useEffect } from 'react'
import Highcharts from 'highcharts'
import HC_more from 'highcharts/highcharts-more'
import HighchartsReact from 'highcharts-react-official'
import BrowserOnly from '@docusaurus/BrowserOnly'


import ExecutionEnvironment from '@docusaurus/ExecutionEnvironment';
import { themes } from 'prism-react-renderer'

if (ExecutionEnvironment.canUseDOM) {
  HC_more(Highcharts)
}

type Role = {
  name: string,
  data: [number, number, number, number, number]
}

//['Technical Expertise', 'System', 'People', 'Process', 'Impact'],
const engineeringRoles: Record<string, Role> = {
  e1: {
    name: 'Associate Engineer',
    data: [1, 1, 1, 1, 1],
  },
  e2: {
    name: 'Engineer',
    data: [2, 2, 2, 2, 2],
  },
  e3: {
    name: 'Senior Engineer',
    data: [3, 3, 3, 3, 2],
  },
  e4: {
    name: 'Principal Engineer',
    data: [4, 4, 3, 4, 3],
  },
  e5: {
    name: 'Distinguished Engineer',
    data: [5, 5, 4, 5, 4],
  }
}



//['Technical Expertise', 'System', 'People', 'Process', 'Impact'],
const engineeringMgmtRoles: Record<string, Role> = {
  em3: {
    name: 'Engineering Manager',
    data: [3, 3, 5, 2, 3],
  },
  em4: {
    name: 'Senior Engineering Manager',
    data: [3, 4, 5, 4, 3],
  },
  em5: {
    name: 'Engineering Head',
    data: [3, 4, 5, 5, 4],
  }
}
//['Technical Expertise', 'Research Metodology', 'People', 'Process', 'Impact'],
const researchRoles: Record<string, Role> = {
  er1: {
    name: 'Associate Engineer in Research',
    data: [1, 1, 1, 1, 1],
  },
  er2: {
    name: 'Engineer in Research',
    data: [2, 2, 2, 2, 2],
  },
  er3: {
    name: 'Senior Engineer in Research',
    data: [3, 3, 3, 3, 2],
  },
  e4: {
    name: 'Principal Engineer in Research',
    data: [4, 4, 3, 4, 3],
  },
  e5: {
    name: 'Distinguished Engineer in Research',
    data: [5, 5, 4, 5, 4],
  }
}

const engineerLabels = {
  "Technical Expertise": ['', 'Adopts', 'Specializes', 'Evangelizes', 'Masters', 'Creates'],
  "System": ['', 'Enhances', 'Designs', 'Owns', 'Evolves', 'Leads'],
  "People": ['', 'Learns', 'Supports', 'Mentors', 'Coordinates', 'Manages'],
  "Process": ['', 'Follows', 'Enforces', 'Challenges', 'Adjusts', 'Defines'],
  "Impact": ['', 'Component', 'Stream', 'Program', 'Multiple Programs', 'Company']
};

const researcherLabels = {
  "Technical Expertise": ['', 'Adopts', 'Specializes', 'Evangelizes', 'Masters', 'Creates'],
  "Research Metodology": ['', 'Executes', 'Analyzes', 'Proposes', 'Leads', 'Expands'],
  "People": ['', 'Learns', 'Supports', 'Mentors', 'Coordinates', 'Manages'],
  "Process": ['', 'Follows', 'Enforces', 'Challenges', 'Adjusts', 'Defines'],
  "Impact": ['', 'Component', 'Stream', 'Program', 'Multiple Programs', 'Company']
};

enum LadderType {
  ENG = "engineer",
  ENG_MGMT = "engineer_management",
  RESEARCHER = "researcher"
}

const EngLadderGraph = function ({ type }: { type: LadderType }) {

  const backgroundColor = themes.dracula.plain.backgroundColor;
  const color = themes.dracula.plain.color;

  const labelArray: Record<string, string[]> = type === LadderType.RESEARCHER ? researcherLabels : engineerLabels;

  let roles: Record<string, Role> = {}

  if (type === LadderType.RESEARCHER) {
    roles = researchRoles
  }
  if (type === LadderType.ENG) {
    roles = engineeringRoles
  }
  if (type === LadderType.ENG_MGMT) {
    roles = engineeringMgmtRoles
  }
  const [role, setRole] = useState(Object.keys(roles)[0]);
  const [result, setResult] = useState<[number, number, number, number, number]>([1,1,1,1,1]);

  const defaultSeries = [];
  const categories = Object.keys(labelArray);
  for (var i = 0; i <= 5; i++) {
    defaultSeries.push({
      name: 'dummy series #' + i + ' for label placement',
      data: [
        { name: labelArray[categories[0]][i], y: i },
        { name: labelArray[categories[1]][i], y: i },
        { name: labelArray[categories[2]][i], y: i },
        { name: labelArray[categories[3]][i], y: i },
        { name: labelArray[categories[4]][i], y: i }
      ],
      dataLabels: {
        enabled: true, padding: 0, y: 0,
        formatter: function () {
          return '<span style="font-weight: normal; font-size: 0.9rem; color: white !important">' + this.point.name + '</span>';
        }
      },
      pointPlacement: 'on',
      lineWidth: 0,
      color: 'transparent',
      showInLegend: false,
      enableMouseTracking: false
    });
  }

  const options: Highcharts.Options = {
    chart: {
      polar: true,
      type: 'line',
      spacingLeft: 30,      // Adjust left spacing as needed
      spacingRight: 30,      // Adjust right spacing as needed
      marginRight: 30,
      backgroundColor,
    },
    title: undefined,
    pane: {
      size: '80%'
    },
    xAxis: {
      categories: Object.keys(labelArray),
      tickmarkPlacement: 'on',
      lineWidth: 0,
      labels: {
        distance: 40,
        style: {
          color,
          fontSize: '1.2rem'
        }
      }
    },
    yAxis: {
      gridLineInterpolation: 'polygon',
      lineWidth: 0,
      labels: {
        enabled: false,
      },
      min: 0, max: 6,
      tickInterval: 1,
      alignTicks: true,
    },
    tooltip: {
      enabled: true,
      shared: true
    },
    legend: {
      align: 'right',
      verticalAlign: 'top',
      y: 70,
      layout: 'vertical',
      itemStyle: {
        color,
      }
    },
    series: [
      ...defaultSeries,
      {
        id: "selectedRole",
        name: roles[role].name,
        data: [...roles[role].data],
        pointPlacement: 'on',
      },
      {
        id: "customResult",
        name: 'Your Result',
        data: result,
        pointPlacement: 'on'
      },
    ]
  }

  const onRoleSelect: ChangeEventHandler<HTMLSelectElement> = function (event) {
    setRole(event.target.value)
  }

  const onCompareAtributeSelect: ChangeEventHandler<HTMLSelectElement> = function (event) {
    result[Number.parseInt(event.target.id)] = Number.parseInt(event.target.options[event.target.options.selectedIndex].value)
    setResult([...result]);
  }

  return (
    <BrowserOnly fallback={<div>Loading...</div>}>
      {
        () => {
          return (
            <div>

      <div className='dashboard'>
        <div className='compareRole'>
          <label>
            Select role to compare:
          </label>
          <select className='dropdown' name="roles" id="roles" onChange={onRoleSelect} value={role} >
            {Object.entries(roles).map(([id, value]) => {
              return (
                <option key={id} value={id}>{value.name}</option>
              )
            })}
          </select>
        </div>

        <div className='compare'>
          <span>Your results:</span>
          <br></br>
          {
            categories.map((category, categoryIndex) => {
              return (
                <div key={category}>
                   <label>
                    {category}
                  </label>
                  <select id={String(categoryIndex)} name={category} onChange={onCompareAtributeSelect}>
                    {
                      labelArray[category].filter((r) => r !== '').map((value, index) => {
                        return (
                          <option key={category+index} value={String(index+1)}>{value}</option>
                        )
                      })
                    }
                  </select>
                </div>
              )
            })
          }
        </div>
      </div>
      <div style={{ height: '60rem' }}>
        <HighchartsReact
          containerProps={{ style: { height: "100%", width: "100%" } }}
          highcharts={Highcharts}
          options={options}
          updateArgs={[true, true, true]}
        />
      </div>
    </div>
          )
        }
      }
    </BrowserOnly>
  );
}

export default EngLadderGraph;