---
sidebar_position: 4
collapsible: true
collapsed: false
---

# Departments

ChainSafe's engineering consists of 4 departments (Consulting, Products, Protocols, Solutions). Each department is focusing
on different parts of the ChainSafe business and has a slightly different way of doing things.
You can read more about each of them in the following sections.

## Engineering Reporting Structure

Every Engineer reports to a Team Lead. All Team Leads report to a Head of Engineering. There are several Head of Engineering positions that have discrete domains (e.g. Head of Protocol Implementations, Head of Engineering, General Consulting). All Heads of Engineering report to the VP of Engineering who reports to the CTO. All Team Leads, Heads of Engineering and the VP of Engineering are on the Engineering Management career track.

Keep in mind this only defines the reporting structure and not the functional interactions with the organization.

```mermaid
graph TD;
    CTO --> A{VP Engineering};
    A --> B1{Head of Protocol Development};
        B1 --> TL11[Team Lead];
            TL11 --> E1{Engineers}; 
        B1 --> TL12[Team Lead];
            TL12 --> E2{Engineers}; 
    A --> B2{Head of Product};
        B2 --> TL21[Team Lead];
            TL21 --> E3{Engineers}; 
        B2 --> TL22[Team Lead];
            TL22 --> E4{Engineers}; 
    A --> B3{Head of Solutions};
        B3 --> TL31[Team Lead];
            TL31 --> E5{Engineers}; 
        B3 --> TL32[Team Lead];
            TL32 --> E6{Engineers}; 
    A --> B4{Head of Consulting};
        B4 --> TL41[Team Lead];
            TL41 --> E7{Engineers}; 
        B4 --> TL42[Team Lead];
            TL42 --> E8{Engineers}; 
```