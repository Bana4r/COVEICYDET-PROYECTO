import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-registro-proyecto',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './registro-proyecto.html',
  styleUrl: './registro-proyecto.css'
})
export class RegistroProyecto {
  model = {
    institucion: '',
    areaAdscripcion: '',
    responsables: {
      legal: { nombre: '', correo: '', telefono: '' },
      tecnico: { nombre: '', correo: '', telefono: '' },
      administrativo: { nombre: '', correo: '', telefono: '' }
    },
    convocatoria: '',
    areaConocimiento: '',
    sectorDesarrollo: '',
    nivelMaduracion: { trl: null as number | null, srl: null as number | null }
  };

  // Archivo probatorio de maduración
  maduracionFile: File | null = null;
  maduracionFileName = '';

  // Catálogos
  convocatorias = [
    'Atención a temas prioritarios del PVD 2025',
    'Programas estratégicos nacionales 2025'
  ];

  nivelTRL = [
    { value: 1, label: 'TRL 1', desc: 'Principios básicos observados y reportados. Investigación básica.' },
    { value: 2, label: 'TRL 2', desc: 'Concepto y aplicación formulada.' },
    { value: 3, label: 'TRL 3', desc: 'Prueba de concepto.' },
    { value: 4, label: 'TRL 4', desc: 'Validación de componentes a nivel laboratorio/campo.' },
    { value: 5, label: 'TRL 5', desc: 'Validación de componentes en un entorno relevante.' },
    { value: 6, label: 'TRL 6', desc: 'Demostración tecnológica en un ambiente relevante.' },
    { value: 7, label: 'TRL 7', desc: 'Demostración de prototipo a nivel sistema en un ambiente operativo real.' },
    { value: 8, label: 'TRL 8', desc: 'Desarrollo de producto completo y evaluado.' },
    { value: 9, label: 'TRL 9', desc: 'Producto terminado con éxito en el entorno real.' }
  ];

  nivelSRL = [
    { value: 1, label: 'SRL 1', desc: 'Identificación del problema y su impacto social.' },
    { value: 2, label: 'SRL 2', desc: 'Formulación del problema, propuesta de soluciones e impacto potencial.' },
    { value: 3, label: 'SRL 3', desc: 'Inicio de pruebas en campo con el grupo de interés.' },
    { value: 4, label: 'SRL 4', desc: 'Problema validado mediante prueba piloto en entorno relevante.' },
    { value: 5, label: 'SRL 5', desc: 'Solución validada por el grupo de interés relevante en el área.' },
    { value: 6, label: 'SRL 6', desc: 'Adopción de la solución.' },
    { value: 7, label: 'SRL 7', desc: 'Impacto social.' }
  ];

  sectores = [
    'Acuicultura',
    'Agrícola – agroindustrial',
    'Alimentos',
    'Ambiente',
    'Educación',
    'Electrónica',
    'Energía',
    'Ingeniería',
    'Medicina y farmacéutica',
    'Química'
  ];

  areasConocimiento: string[] = [
    'Ciencias Físico-Matemáticas y de la Tierra',
    'Biología y Química',
    'Medicina y Ciencias de la Salud',
    'Humanidades y Ciencias de la Conducta',
    'Ciencias Sociales y Económicas',
    'Biotecnología y Ciencias Agropecuarias',
    'Ingenierías'
  ];

  onFileChange(e: Event) {
    const input = e.target as HTMLInputElement;
    this.maduracionFile = input.files?.[0] ?? null;
    this.maduracionFileName = this.maduracionFile ? this.maduracionFile.name : 'Seleccionar archivo PDF';
  }

  saveDraft() { /* demo */ }
  onSubmit() { /* demo */ }
}
