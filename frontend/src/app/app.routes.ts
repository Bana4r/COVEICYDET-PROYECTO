import { Routes } from '@angular/router';
import { RegistroProyectoContenedor } from './registro-de-proyecto/registro-proyecto-contenedor/registro-proyecto-contenedor';
import { RegistroProyecto } from './registro-de-proyecto/registro-proyecto/registro-proyecto';
import { RegistroProyecto2 } from './registro-de-proyecto/registro-proyecto2/registro-proyecto2';
import { RegistroProyecto3 } from './registro-de-proyecto/registro-proyecto3/registro-proyecto3';
import { RegistroProyecto4 } from './registro-de-proyecto/registro-proyecto4/registro-proyecto4';

export const routes: Routes = [
  /*{ path: 'registro-proyecto', component: RegistroProyecto },
  { path: 'registro-proyecto2', component: RegistroProyecto2 },
  { path: 'registro-proyecto3', component: RegistroProyecto3 },*/
  {
    path: 'registro-proyecto',
    component: RegistroProyectoContenedor, // contenedor
    children: [
      { path: '', redirectTo: 'paso1', pathMatch: 'full' },
      { path: 'paso1', component: RegistroProyecto },
      { path: 'paso2', component: RegistroProyecto2 },
      { path: 'paso3', component: RegistroProyecto3 },
      { path: 'paso4', component: RegistroProyecto4 },
    ]
  },
  { path: '**', redirectTo: 'registro-proyecto' }
];