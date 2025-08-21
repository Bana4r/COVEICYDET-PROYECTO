import { ComponentFixture, TestBed } from '@angular/core/testing';

import { RegistroProyecto4 } from './registro-proyecto4';

describe('RegistroProyecto4', () => {
  let component: RegistroProyecto4;
  let fixture: ComponentFixture<RegistroProyecto4>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [RegistroProyecto4]
    })
    .compileComponents();

    fixture = TestBed.createComponent(RegistroProyecto4);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
