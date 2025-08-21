import { Routes } from '@angular/router';
import { Componente } from './login-y-logica/componente/componente';
import { Login } from './login-y-logica/login/login';
import { ResponsableDeProyectoContenedor } from './responsable-del-proyecto/responsable-de-proyecto-contenedor/responsable-de-proyecto-contenedor';
import { RegistroProyecto } from './responsable-del-proyecto/registro-de-proyecto/registro-proyecto/registro-proyecto';
import { RegistroProyecto2 } from './responsable-del-proyecto/registro-de-proyecto/registro-proyecto2/registro-proyecto2';
import { RegistroProyecto3 } from './responsable-del-proyecto/registro-de-proyecto/registro-proyecto3/registro-proyecto3';
import { RegistroProyecto4 } from './responsable-del-proyecto/registro-de-proyecto/registro-proyecto4/registro-proyecto4';
import { PaginaPrincipal } from './responsable-del-proyecto/pagina-principal/pagina-principal';

export const routes: Routes = [
  {
    path: 'main',
    component: Componente,
    children: [
      { path: '', redirectTo: 'login', pathMatch: 'full' },
      { path: 'login', component: Login }
    ]
  },

  {
    /* responsable de proyecto */
    /* pagina principal */
    path: 'responsable-de-proyecto',
    component: ResponsableDeProyectoContenedor, // contenedor
    children: [
      { path: '', redirectTo: 'pagina-principal', pathMatch: 'full' },
      { path: 'pagina-principal', component: PaginaPrincipal } // nueva ruta para la página principal
    ],
  },

  {
    /* registro de proyecto */
    path: 'responsable-de-proyecto/registro-proyecto',
    component: ResponsableDeProyectoContenedor,
    children: [
      {path: 'paso1', component: RegistroProyecto},
      {path: 'paso2', component: RegistroProyecto2},
      {path: 'paso3', component: RegistroProyecto3},
      {path: 'paso4', component: RegistroProyecto4},
    ],
  },
  { path: '**', redirectTo: 'main' }
];