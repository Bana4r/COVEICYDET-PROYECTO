import { ComponentFixture, TestBed } from '@angular/core/testing';

import { RegistroProyecto2 } from './registro-proyecto2';

describe('RegistroProyecto2', () => {
  let component: RegistroProyecto2;
  let fixture: ComponentFixture<RegistroProyecto2>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [RegistroProyecto2]
    })
    .compileComponents();

    fixture = TestBed.createComponent(RegistroProyecto2);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
